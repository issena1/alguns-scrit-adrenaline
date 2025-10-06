import logging
import os
from telegram import Update, InputFile
from telegram.ext import Application, MessageHandler, filters, ContextTypes, CommandHandler
import asyncio
import Print

# --- Configuração do Bot Telegram ---
f = open('token.txt')
TOKEN = f.read().replace('\n', '')
f.close()

# --- Lista de comando sem argument ---
l = ['unstuck']
# -- Comandos com Argument ---
arglist = ['talk', 'dlg', 'teleport', 'unstuck', 'move', 'GK']
# --- Configuração de Logging ---
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.WARNING
)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Reduz log de bibliotecas
for lib in ("httpx", "telegram", "asyncio"):
    logging.getLogger(lib).setLevel(logging.WARNING)

# Variável global para controle do monitoramento
monitor_tasks = {}

async def is_private_chat(update: Update) -> bool:
    """Verifica se a mensagem vem de um chat privado"""
    return update.effective_chat.type == "private"

async def handle_private_messages(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Processa apenas mensagens privadas"""
    if not await is_private_chat(update):
        return

    user = update.effective_user
    
    try:
        if update.message.text:
            logger.info(f"Msg privada de {user.full_name}: {update.message.text}")
            response = (
                "👋 Olá!\n\n"
                "📌 Comandos disponíveis:\n"
                "/p or /print - Envia print\n"
                "/talk <Nome_NPC> - Inicia diálogo com NPC\n"
                "/teleport <Local> - Teleporta para o local\n"
                "/dlg <Nome_opção> - Fala com NPC na opção escolhida\n"
                "/unstuck - usa comando /unstuck\n"
                "/stop_talk - Para o monitoramento\n"
                "/help - Ajuda"
            )
            await update.message.reply_text(response)
        else:
            await update.message.reply_text("⚠️ Envie apenas mensagens de texto ou use os comandos.")

    except Exception as e:
        logger.error(f"Erro ao processar mensagem: {e}")
        await update.message.reply_text("❌ Ocorreu um erro ao processar sua mensagem.")

async def send_image(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handler para envio de imagens apenas em chats privados"""
    if not await is_private_chat(update):
        return

    user = update.effective_user
    
    try:
        Print.capture_specific_window('Lineage II', 'Fota.png')
        with open('fota.png', 'rb') as img:
            await context.bot.send_photo(
                chat_id=update.effective_chat.id,
                photo=InputFile(img),
                caption=f"🖼️ {user.first_name}, aqui está seu print!",
                parse_mode='Markdown'
            )
        logger.info(f"Imagem enviada para {user.full_name}")

    except Exception as e:
        logger.error(f"Erro ao enviar imagem: {e}")
        await update.message.reply_text("⚠️ Falha ao enviar imagem. Tente novamente.")

async def monitorar_arquivo(chat_id, context: ContextTypes.DEFAULT_TYPE):
    """Monitora continuamente o arquivo talkpas.txt"""
    arquivo_alvo = 'talkpas.txt'
    try:
        while True:
            if os.path.exists(arquivo_alvo):
                try:
                    with open(arquivo_alvo, 'r') as f:
                        conteudo = f.read().strip()
                        f.close()
                        os.remove(arquivo_alvo)
                        
                        if conteudo == 'true':
                            await context.bot.send_message(
                                chat_id=chat_id,
                                text="✅ Comando confirmado!"
                            )
                        elif conteudo == 'false':
                            await context.bot.send_message(
                                chat_id=chat_id,
                                text="❌ Comando não foi possível!"
                            )
                        elif conteudo == 'caminhando':
                            await context.bot.send_message(
                                chat_id=chat_id,
                                text="Movendo Aguarde!"
                            )
                        elif conteudo == 'unstuck':
                            await context.bot.send_message(
                                chat_id=chat_id,
                                text="Unstuck Finalizado!"
                            )
                        elif 'gk' in conteudo.lower():
                            conteudo = conteudo.split()[1]
                            await context.bot.send_message(
                                chat_id=chat_id,
                                text=f"Chegou na GK {conteudo}!"
                            )
                            return True
                except Exception as e:
                    logger.error(f"Erro ao ler arquivo: {e}")
                    await asyncio.sleep(1)
            
            await asyncio.sleep(2)
            
    except asyncio.CancelledError:
        logger.info(f"Monitoramento cancelado para chat {chat_id}")
        return False

async def enviar_comando(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Processa comandos apenas em chats privados"""
    if not await is_private_chat(update):
        return

    chat_id = update.effective_chat.id
    user = update.effective_user

    com = update.message.text.split()[0][1:]
    
    if not context.args and not com in l :
        await update.message.reply_text(f"⚠️ Uso: {update.message.text} <Argumento>")
        return
    
    # Cancela monitoramento anterior se existir
    if chat_id in monitor_tasks:
        monitor_tasks[chat_id].cancel()
        del monitor_tasks[chat_id]
    
    # Escreve o comando no arquivo
    comando = update.message.text.replace('/', '')
    try:
        with open('talkpy.txt', 'w') as f:
            f.write(update.message.text.replace('/', ''))

        logger.info(f"Comando {comando} escrito para {user.full_name}")
    except Exception as e:
        logger.error(f"Erro ao escrever arquivo: {e}")
        await update.message.reply_text("❌ Erro ao executar comando.")
        return
    
    # Inicia monitoramento em segundo plano
    monitor_tasks[chat_id] = asyncio.create_task(
        monitorar_arquivo(chat_id, context))
    
    await update.message.reply_text("⏳ Esperando resposta...")

async def stop_talk(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Para o monitoramento apenas em chats privados"""
    if not await is_private_chat(update):
        return

    chat_id = update.effective_chat.id
    
    if chat_id in monitor_tasks:
        monitor_tasks[chat_id].cancel()
        del monitor_tasks[chat_id]
        await update.message.reply_text("⏹️ Monitoramento parado.")
    else:
        await update.message.reply_text("ℹ️ Nenhum comando sendo monitorado.")

def main():
    """Configuração completa do bot"""
    app = Application.builder().token(TOKEN).build()

    # Filtro para aceitar apenas mensagens privadas
    private_filter = filters.ChatType.PRIVATE

    # Handlers
    app.add_handler(CommandHandler(["p", "print"], send_image, filters=private_filter))
    app.add_handler(CommandHandler("help", handle_private_messages, filters=private_filter))
    app.add_handler(CommandHandler(arglist, enviar_comando, filters=private_filter))
    app.add_handler(CommandHandler("stop", stop_talk, filters=private_filter))
    app.add_handler(MessageHandler(private_filter & filters.TEXT, handle_private_messages))
    
    logger.info("Bot iniciado!")
    app.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    main()
