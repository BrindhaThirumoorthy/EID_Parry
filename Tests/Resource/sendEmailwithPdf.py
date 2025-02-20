from datetime import datetime
import requests
import sys
import os
import pandas as pd

def get_access_token(client_id, client_secret, tenant_id):
    try:
        token_url = f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token"
        headers = {
            'Content-Type': 'application/x-www-form-urlencoded'
        }
        body = {
            'client_id': client_id,
            'client_secret': client_secret,
            'scope': 'https://graph.microsoft.com/.default',
            'grant_type': 'client_credentials'
        }

        response = requests.post(token_url, headers=headers, data=body)
        
        if response.status_code == 200:
            access_token = response.json().get('access_token')
            return access_token
        else:
            raise Exception(f"Failed to get access token: {response.status_code}, {response.json()}")

    except Exception as e:
        raise Exception(f"Error: {str(e)}")

def get_email_recipients(number: int, dataframe: pd.DataFrame) -> tuple:
    try:
        # Filter the row where the 'Business Partner Number' matches the input number
        row = dataframe.loc[dataframe['Business Partner Number'] == number]
        
        if row.empty:
            # raise ValueError(f"Number {number} not found in 'Business Partner Number' column.")
            return None, None
        
        # Extract 'TO' and 'CC' values from the matching row
        to_recipients = row.iloc[0]['TO']
        cc_recipients = row.iloc[0]['CC']
        
        return to_recipients, cc_recipients
    except Exception as e:
        # raise ValueError(f"Error occurred: {str(e)}")
        print(f"Error occurred while fetching email details: {str(e)}")
        return None, None

def send_email_with_attachment(client_id, client_secret, tenant_id, to_recipients, cc_recipients, subject, body, file_path):
    try:
        access_token = get_access_token(client_id, client_secret, tenant_id)
        
        recipients = [{'emailAddress': {'address': email}} for email in to_recipients if email]
        cc_recipients_list = [{'emailAddress': {'address': email}} for email in cc_recipients if email]

        email_payload = {
            "message": {
                "subject": subject,
                "body": {
                    "contentType": "HTML",
                    "content": body
                },
                "toRecipients": recipients,
                "ccRecipients": cc_recipients_list
            },
            "saveToSentItems": "true"
        }

        if file_path and os.path.isfile(file_path):
            with open(file_path, 'rb') as file:
                file_data = file.read()
            import base64
            encoded_file = base64.b64encode(file_data).decode('ISO-8859-1')

            attachment = {
                "@odata.type": "#microsoft.graph.fileAttachment",
                "name": os.path.basename(file_path),
                "contentBytes": encoded_file
            }
            
            email_payload['message']['attachments'] = [attachment]

        url = 'https://graph.microsoft.com/v1.0/users/ecollections@parry.murugappa.com/sendMail'

        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json'
        }
        
        response = requests.post(url, headers=headers, json=email_payload)
        
        if response.status_code == 202:
            return f"Email sent successfully to {', '.join(to_recipients)} and CC to {', '.join(cc_recipients)}."
        else:
            return f"Error sending email: {response.status_code}, {response.json()}"
            sys.exit()
    
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    print(sys.argv)
    print(len(sys.argv))
    try:
        client_id = sys.argv[1]
        client_secret = sys.argv[2]
        tenant_id = sys.argv[3]
        
        bp_email_details_file = sys.argv[4]
        if not os.path.isfile(bp_email_details_file):
            raise FileNotFoundError(f"File '{bp_email_details_file}' does not exist.")

        dataframe = pd.read_excel(bp_email_details_file)
        # print(dataframe.head())
        if dataframe.empty:
            raise ValueError(f"The CSV file '{bp_email_details_file}' is empty.")

        invoice_number = int(sys.argv[5])
        bp_number = int(sys.argv[6])
        to_recipients_string, cc_recipients_string = get_email_recipients(bp_number, dataframe)

        if to_recipients_string is None or cc_recipients_string is None:
            print("There is no data for the Business Process Number {bp_number}.")
            print(f"##gbStart##mail_status#splitKeyValue##There is no data for the Business Process Number {bp_number}.##gbEnd##")
            print(f"##gbStart##copilot_status##splitKeyValue##No data found in the excel for the Business Process Number {bp_number} for the invoice {invoice_number}.##splitKeyValue##object##gbEnd##")
            sys.exit(0)
        
        to_recipients = [i.strip() for i in to_recipients_string.split(';') if i.strip()]
        cc_recipients = [i.strip() for i in cc_recipients_string.split(';') if i.strip()]

        
        print("TO Recipients:", to_recipients)
        print("CC Recipients:", cc_recipients)
        subject1 = sys.argv[7]
        print(subject1)
        subject2 = sys.argv[8]
        print(subject2)
        subject = f"{subject1}{subject2}"
        print(subject)
        body1 = sys.argv[9]
        body2 = sys.argv[10]
        body3 = sys.argv[11]
        body4 = sys.argv[12]
        body = f"{body1}<br><br>{body2}{subject2}<br><br>{body3}<br>{body4}"
        print(body)
        
        now = datetime.now()
        current_month = now.strftime("%B")
        current_year = now.year
        folder_path = os.path.join(sys.argv[13], str(current_year), current_month)
        # folder_path = sys.argv[8]
        file_name = sys.argv[14]
        file_path = os.path.join(folder_path, file_name)
        if not os.path.isfile(file_path):
            raise FileNotFoundError(f"Attachment file '{file_path}' does not exist.")
        
        if len(sys.argv) == 15:
            file_path = os.path.join(folder_path, file_name)
            if os.path.isfile(file_path):
                result = send_email_with_attachment(
                    client_id, 
                    client_secret, 
                    tenant_id, 
                    to_recipients, 
                    cc_recipients, 
                    subject, 
                    body,
                    file_path
                )
            else:
                result = f"Error: File '{file_path}' does not exist."
                sys.exit(1)
            print(result)
            print("Script Processed Successfully")
            print(f"##gbStart##copilot_status##splitKeyValue##Mail sent successfully for the invoice {invoice_number} & Business Process Number {bp_number}.##splitKeyValue##object##gbEnd##")
        else:
            print(f"Usage error: {sys.argv[0]} <client_id> <client_secret> <tenant_id> <bp_email_details_file> <bp_number> <subject> <body> <folder_path> <file_name>")
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
