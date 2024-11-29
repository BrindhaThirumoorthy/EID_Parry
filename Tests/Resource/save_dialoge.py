# from pywinauto import Application, Desktop
# import time

# # Connect to the SAP Logon application
# sap_app = Application(backend="uia").connect(title_re="Print Preview of LOCA Page 00001 of 00002", timeout=10)

# # Wait for the "Save As" dialog to appear
# for _ in range(5):
#     try:
#         save_dialog = Desktop(backend="uia").window(title_re=".*Save Print Output As.*")
#         if save_dialog.exists():
#             break
#     except:
#         time.sleep(1)

# # If not found, raise an error
# if not save_dialog.exists():
#     raise RuntimeError("Save As dialog not found.")

from pywinauto import Desktop

# List all open windows
windows = Desktop(backend="uia").windows()
for win in windows:
    print(win.window_text())
