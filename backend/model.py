import xml.etree.ElementTree as ET
import pandas as pd
import threading
import requests
import json
import re
# OpenAI access_token generation
with open("config.json", "r") as file:
    credentials = json.load(file)
file.close()


def getAccessToken():
    client_id = credentials.get("client_id")
    client_secret = credentials.get("client_secret")
    uaa_url = credentials.get("uaa_url")

    params = {"grant_type": "client_credentials"}
    resp = requests.post(f"{uaa_url}/oauth/token",
                         auth=(client_id, client_secret),
                         params=params)

    token = resp.json()["access_token"]

    return token


def extract_code_from_response(generated_text):
    generated_text = str(generated_text)
    pattern = r"```xml([\s\S]*?)```"
    matches = re.finditer(pattern, generated_text, re.DOTALL)
    matches_list = [match.group(1) for match in matches]
    return matches_list


# def check_root_exists(xsl_string):
#     pattern = r"<root>"
#     matches = re.findall(pattern, xsl_string, re.DOTALL)
#     return False if len(matches) == 0 else True


def combine_xslt_strings(xslt_strings):
    combined_inside_root = []
    combined_outside_root = []

    for xslt_string in xslt_strings:
        content_match = re.search(
            r"<root>(.*?)</root>", xslt_string, re.DOTALL)
        if content_match:
            combined_inside_root.append(content_match.group(1))
        else:
            combined_outside_root.append(xslt_string)

    dynamic_content = ""
    if combined_inside_root:
        dynamic_content = combined_inside_root[0]
        combined_inside_root.pop(0)

    result = '<?xml version="1.0" encoding="UTF-8"?>\n'
    result += '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\n'
    result += '    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">\n'
    result += '    <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>\n'
    result += '    <xsl:param name="anPayloadID"/>\n'
    result += '    <xsl:param name="documentreceiptdate"/>\n'
    result += f'    <xsl:template match="Combined">\n{dynamic_content}\n    </xsl:template>\n'

    if combined_inside_root:
        result += '\n'.join(combined_inside_root) + '\n'
    if combined_outside_root:
        result += '\n'.join(combined_outside_root) + '\n'

    result += '</xsl:stylesheet>'

    return result


def merge_xml_strings(xml_strings):
    # Extract the root element from the first XML string
    root_match = re.search(r"<root>(.*?)</root>", xml_strings[0], re.DOTALL)
    if root_match:
        root_content = root_match.group(1)
        modified_xml = f"<root>{root_content}</root>"

        # Loop through the remaining XML strings and append content to modified_xml
        for xml_string in xml_strings[1:]:
            content_match = re.search(
                r"<root>(.*?)</root>", xml_string, re.DOTALL)
            if content_match:
                root_content = content_match.group(1)
                modified_xml += root_content
    else:
        modified_xml = xml_strings[0]

        # Loop through the remaining XML strings and append content to modified_xml
        for xml_string in xml_strings[1:]:
            content_match = re.search(
                r"<root>(.*?)</root>", xml_string, re.DOTALL)
            if content_match:
                root_content = content_match.group(1)
                modified_xml += f"<root>{root_content}</root>"

    return modified_xml


def create_xslt(final_string):
    with open("output.xslt", "w") as file:
        file.write(final_string)
    file.close()


def generate_xml(new_df, i, chunks, token, svc_url, output, input, test_df, result_list, lock_list):
    delimiter = "####"

    # Calculate the input range
    if (i + chunks) < len(new_df):
        input2 = test_df[i:i+chunks].to_string()
    else:
        input2 = test_df[i:len(test_df)].to_string()

    system_input = f"""



    You are given the contents of excel sheet in pandas dataframe string format which is mentioned inside the {delimiter}.



    The data is here {delimiter} {input} {delimiter} .When we input this string we get following xml output mentioned inside delimeter {delimiter}



The output is {delimiter} {output} {delimiter}. The taks is to generate the similar output xml for the sample input mentioned by user.The output displayed should only be xml in ```xml content here``` format, do generate for all rows 
"""

    data = {
        "deployment_id": "gpt-4-32k",
        "messages": [
            {"role": "system", "content": f"An interaction between a human and a machine. You have to do the following {system_input}"},
            {"role": "user", "content": f" kindly generate complete xml for this input {input2}, The output displayed should only be xml don't generate description "}
        ],
        "max_tokens": 1200,
        "temperature": 0.7,
        "frequency_penalty": 0,
        "presence_penalty": 0,
        "top_p": 0.95,
        "stop": "null"
    }

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    response = requests.post(
        f"{svc_url}/api/v1/completions", headers=headers, json=data)
    jsonContent = response.json()
    print(jsonContent)
    with lock_list[i // chunks]:
        result_list[i // chunks] = extract_code_from_response(
            jsonContent['choices'][0]['message']['content'])[0]


def gen_AI_model(test_df):
    df = pd.read_excel(
        "cXML Mappings - MAPPING_ANY_cXML_0000_InvoiceDetailRequest_1INV_0000_Invoice.xlsx")
    new_df = df.copy()
    input = new_df.to_string()

    # Read Invoice xslt file and store in output variable
    with open("MAPPING_ANY_cXML_0000_InvoiceDetailRequest_1INV_0000_Invoice.xsl", "r") as file:
        output = file.read()

    file.close()

    chunks = 10  # Adjust the chunk size as needed
    token = getAccessToken()
    svc_url = credentials.get("svc_url")

    threads = []
    # Initialize a list to store results
    result_list = [None] * (len(test_df) // chunks + 1)
    lock_list = [threading.Lock() for _ in range(
        len(test_df) // chunks + 1)]  # Create a list of locks
    i = 0
    while i < len(test_df):
        print(i)
        thread = threading.Thread(target=generate_xml, args=(
            new_df, i, chunks, token, svc_url, output, input, test_df, result_list, lock_list))
        threads.append(thread)
        thread.start()

        i += chunks
    for thread in threads:
        thread.join()

    results = result_list[:-1] if len(df) % chunks == 0 else result_list
    # final_string = merge_xml_strings(results)
    # print(final_string)
    # create_xslt(final_string)
    sol = combine_xslt_strings(results)
    with open("output.xlst", "w") as file:
        file.write(sol)
    file.close()
    print("Done...")
    return sol
