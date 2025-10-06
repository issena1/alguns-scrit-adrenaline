import pyautogui
import pygetwindow as gw # Import pygetwindow for more flexible window searching
import time

def capture_specific_window(title_part: str, output_filename: str = 'fota.png'):
    """
    Captures a screenshot of a specific window by part of its title.

    Args:
        title_part (str): A string that is part of the target window's title.
        output_filename (str): The name of the file to save the screenshot to.
    """
    try:
        # Find windows that contain the title_part (case-insensitive)
        # Using pygetwindow is generally more flexible for finding windows
        found_windows = [
            win for win in gw.getAllWindows()
            if title_part.lower() in win.title.lower() and win.isMinimized == False
        ]

        if not found_windows:
            print(f"Erro: Nenhuma janela com '{title_part}' no título encontrada ou não está visível.")
            print("Verifique se o jogo está aberto e não minimizado.")
            # Opcional: Listar todos os títulos de janelas para depuração
            # print("\nTítulos de todas as janelas abertas:")
            # for win in gw.getAllWindows():
            #     print(f"- {win.title}")
            return False

        # If multiple windows are found, it takes the first one.
        # You might want to add logic to pick a specific one if there are many.
        target_window = found_windows[0]
        print(f"Janela encontrada: '{target_window.title}'")

        # Optional: Activate the window to ensure it's in focus and visible
        # This can sometimes help with screenshot consistency, but might disrupt user.
        try:
            target_window.activate()
            time.sleep(0.5) # Give it a moment to activate
        except gw.PyGetWindowException:
            print(f"Aviso: Não foi possível ativar a janela '{target_window.title}'. Tentando capturar assim mesmo.")
        except Exception as e:
            print(f"Aviso: Erro ao tentar ativar a janela: {e}")

        # Capture the screenshot of the window's region
        screenshot = pyautogui.screenshot(region=(
            target_window.left,
            target_window.top,
            target_window.width,
            target_window.height
        ))

        screenshot.save(output_filename)
        print(f"Screenshot salvo como '{output_filename}' de '{target_window.title}'.")
        return True

    except Exception as e:
        print(f"Ocorreu um erro ao tentar capturar a janela: {e}")
        return False

# --- Como usar ---
if __name__ == "__main__":
    # Altere 'l2.exe' para a parte do título da janela do seu jogo.
    # Por exemplo, se o título for "Lineage II - The Game", você pode usar "Lineage II" ou "The Game".
    # Certifique-se de que a janela esteja aberta e não minimizada!
    target_title_part = 'lineage II' # Ou 'Lineage II', 'L2' etc.

    if capture_specific_window(target_title_part, 'l2_screenshot.png'):
        print("Captura de tela concluída com sucesso.")
    else:
        print("Falha na captura de tela.")
