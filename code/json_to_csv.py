import csv
import json
def json_to_csv(json_file_path, csv_file_path):
    with open(json_file_path, encoding='utf-8') as f:
        iter_f = iter(f)
        line = f.readline()
        names=list(json.loads(line).keys())
        with open(csv_file_path, 'w',encoding='utf-8',newline='') as csvfile:
            fieldnames = names
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            for line in iter_f:
                d = json.loads(line)
                writer.writerow(d)
            csvfile.close()
        f.close()

    
