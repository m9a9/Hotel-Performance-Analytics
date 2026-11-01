import csv

def clean_reports(input_path,output_path):

    with open(input_path,"r",newline="",encoding="cp1256") as infile, \
         open(output_path,"w",newline="",encoding="utf-8-sig") as outfile:

        reader=csv.reader(infile)
        writer=csv.writer(outfile)

        for row in reader:
            if any(cell.strip() for cell in row):
                writer.writerow(row)
    print(f"Done 👌! Report has been cleaned successfully")

#! >>>>>>>>>>>>>>>>>>>>cleaning Customer report files >>>>>>>>>>>>>>>>>>>>>>

clean_reports(input_path=r"DataSet\2022\CustomerReport 2022.csv",
              output_path=r"DataSet\2022\customer_report_2022_cleaned.csv")

clean_reports(input_path=r"DataSet\2023\customer report 2023.csv",
              output_path=r"DataSet\2023\customer_report_2023_cleaned.csv")

clean_reports(input_path=r"DataSet\2024\customer report 2024.csv",
              output_path=r"DataSet\2024\customer_report_2024_cleaned.csv")

clean_reports(input_path=r"DataSet\2025\customer report 2025.csv",
              output_path=r"DataSet\2025\customer_report_2025_cleaned.csv")

clean_reports(input_path=r"DataSet\2026\customer report 2026.csv",
              output_path=r"DataSet\2026\customer_report_2026_cleaned.csv")



#! cleaning Customer report files for aug and septenber 2026
clean_reports(input_path=r"C:\Users\WIN 11\Downloads\CustomerReport.csv",
              output_path=r"C:\Users\WIN 11\Downloads\CustomerReport_cleaned.csv")

