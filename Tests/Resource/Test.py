import win32com.client
import sys
import ast
import  time

def select_layout(session, table_id):
        table = session.findById(table_id)
        row = table.RowCount
        print(row)
        for i in range(row):
            layout_value = table.GetCellValue(i, "TEXT")
            if layout_value == "Contracts - Header":
                table.selectedRows = str(i)
                table.doubleclickCurrentCell
                break
        if layout_value != "Contracts - Header":
            print("No row with 'TEXT' value 'header' found.")

# Simulate the SAP table value retrieval function (you will replace this with the actual logic)
def get_sap_table_value(session, table_id, button_id, search_term):
    table = session.findById(table_id)
    # button = session.findById(button_id)
    row = table.RowCount
    # for j in range(len(search_terms)):
    #     item = search_terms[j]
    try:
        for i in range(row):
            table.currentCellRow = i
            cell_value = table.getCellValue(i, "SELTEXT")
            if cell_value == search_term:
                table.selectedRow = i
                # time.sleep(2)
                # session.sendvkey(7)
                # time.sleep(2)
                # session.sendvkey(7)
    except Exception as e:
                return f"Error: {e}"      
        
def main():
    sapGuiAuto = win32com.client.GetObject("SAPGUI")
    if not sapGuiAuto:
        raise RuntimeError("Cannot find SAP GUI. Please ensure it is running.")
    application = sapGuiAuto.GetScriptingEngine
    connection = application.Children(0)
    session = connection.Children(0)
   
    table_id = "wnd[1]/usr/subSUB_CONFIGURATION:SAPLSALV_CUL_LAYOUT_CHOOSE:0500/cntlD500_CONTAINER/shellcont/shell"
    table_id1 = "wnd[1]/usr/tabsG_TS_ALV/tabpALV_M_R1/ssubSUB_CONFIGURATION:SAPLSALV_CUL_COLUMN_SELECTION:0620/cntlCONTAINER1_LAYO/shellcont/shell"
    button_id = "wnd[1]/usr/tabsG_TS_ALV/tabpALV_M_R1/ssubSUB_CONFIGURATION:SAPLSALV_CUL_COLUMN_SELECTION:0620/btnAPP_WL_SING"
    search_term = "Sold-To Party Name"
    select_layout(session, table_id)
    time.sleep(10)
    # get_sap_table_value(session, table_id1, button_id, search_term)
 
if __name__ == "__main__":
    main()