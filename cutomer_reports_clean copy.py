import csv

def clean_reports_copy(input_path,output_path):

    with open(input_path,"r",newline="",encoding="cp1256") as infile, \
         open(output_path,"w",newline="",encoding="utf-8-sig") as outfile:

        reader=csv.reader(infile)
        writer=csv.writer(outfile)

        for row in reader:
            if any(cell.strip() for cell in row):
                writer.writerow(row)
    print(f"Done 👌! Report has been cleaned successfully")



#! cleaning Customer report files for aug and septenber 2026
clean_reports_copy(input_path=r"C:\Users\WIN 11\Downloads\CustomerReport.csv",
              output_path=r"C:\Users\WIN 11\Downloads\CustomerReport_cleaned.csv")

    