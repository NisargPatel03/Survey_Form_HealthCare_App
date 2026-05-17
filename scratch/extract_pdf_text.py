import os
import subprocess
import sys

def install_and_import(package):
    try:
        __import__(package)
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])

install_and_import('pypdf')

from pypdf import PdfReader

def extract_pdf_to_txt(pdf_path, txt_path):
    print(f"Extracting {pdf_path}...")
    reader = PdfReader(pdf_path)
    text = ""
    for page in reader.pages:
        text += page.extract_text() + "\n--- PAGE BREAK ---\n"
    
    with open(txt_path, 'w', encoding='utf-8') as f:
        f.write(text)
    print(f"Saved to {txt_path}")

if __name__ == '__main__':
    extract_pdf_to_txt('../5th_Sem_Marksheet.pdf', '5th_Sem_Marksheet_extracted.txt')
    extract_pdf_to_txt('../7th_Sem_Marksheet.pdf', '7th_Sem_Marksheet_extracted.txt')
