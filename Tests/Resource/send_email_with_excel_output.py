from datetime import datetime
import requests
import sys
import os
import pandas as pd
import base64

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
            raise ValueError(f"Number {number} not found in 'Business Partner Number' column.")
        
        # Extract 'TO' and 'CC' values from the matching row
        to_recipients = row.iloc[0]['TO']
        cc_recipients = row.iloc[0]['CC']
        
        return to_recipients, cc_recipients
    except Exception as e:
        raise ValueError(f"Error occurred: {str(e)}")

def send_email_with_attachment(client_id, client_secret, tenant_id, to_recipients, cc_recipients, subject, body, file_path):
    try:
        access_token = get_access_token(client_id, client_secret, tenant_id)
        
        # Prepare recipient list
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

        # Attach file if it exists
        if file_path and os.path.isfile(file_path):
            with open(file_path, 'rb') as file:
                file_data = file.read()
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
        
        # Send email request
        response = requests.post(url, headers=headers, json=email_payload)
        
        if response.status_code == 202:
            return f"Email sent successfully to {', '.join(to_recipients)} and CC to {', '.join(cc_recipients)}."
        else:
            return f"Error sending email: {response.status_code}, {response.json()}"
    
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    print(sys.argv)
    print(len(sys.argv))
    try:
        client_id = sys.argv[1]
        client_secret = sys.argv[2]
        tenant_id = sys.argv[3]
        
        to_recipients = [email.strip() for email in sys.argv[4].split(',')]
        cc_recipients = [email.strip() for email in sys.argv[5].split(',')] if len(sys.argv) > 5 else []
        
        if len(to_recipients) > 3:
            raise ValueError("No more than 3 TO recipients allowed.")
        if len(cc_recipients) > 3:
            raise ValueError("No more than 3 CC recipients allowed.")

        print("TO Recipients:", to_recipients)
        print("CC Recipients:", cc_recipients)

        subject = sys.argv[6]
        body = sys.argv[7]
        
        folder_path = sys.argv[8]
        
        file_name = sys.argv[9]
        file_path = os.path.join(folder_path, file_name)
        
        if not os.path.isfile(file_path):
            raise FileNotFoundError(f"Attachment file '{file_path}' does not exist.")

        # Send email with attachment
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
        
        print(result)
        print("Script Processed Successfully")
        
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
