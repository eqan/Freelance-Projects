Steps Before Running the script:
1. Put your chrome driver inside this folder
2. "pip install openpyxl" if you dont have openpyxl installed
3. Add your data to the prefix and suffix file which will generate a master list of combinations automatically by the program

Things you need to know:
1. The history file will contain the log of the processed domains
2. The MasterList will only be computed once if you delete the file the program will automatically regenerate the master list using prefix and suffix file
3. The MasterList will delete row one by one which is processed and will store the history to the History file thus this means it will continue processing the domains which are still to be searched whilst the searched domains will be eradicated from the MasterList file.
