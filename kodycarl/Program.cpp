#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>
#include <ctime>
#include <string>
#include <cstdlib>

using namespace std;

void login();
void mainMenu();
void libraryMainPage(string userName, string userType);
void reWriteFile(vector<string> data, string fileName);

/*
Requirements

✅The program must be able to manage at least two files: one containing the list of books and their characteristics and another with
 the list of library users.

✅• Users have a login, a personal password, as well as a role (student or teacher).

✅• Books have a title, an author, an identification number and a category to which they belong (science, literature, etc.)

✅• Library Rules: A student can borrow up to 3 books that he can keep each for 2 minutes. A teacher can borrow a maximum of 5 books that he
 can keep for 3 min. In case of delay on a return, the user can not borrow a new book. A teacher can also add an additional book to the
  library's book stock.

✅• When running the application, the user must first make the choice between logging in (he must then enter his login + password) or create
 a new account.

✅• Once logged in, a message will indicate to the user the list of books already borrowed as well as the maximum time of return of these books.
 He will then have the choice between returning a book or borrowing another (within the framework of the rules mentioned above).

✅• In the context where the user wishes to borrow a book, he will be able to search and display the available books by displaying them
 in alphabetical order according to their title or author. He will also be able to search by category.

✅• It is of course impossible to borrow a book already borrowed by someone else (there is only one copy of each book in this library)
*/


vector<string> students, teachers, books, borrowedBooks, availableBooks;
vector<vector<string>> currentUserBorrowedBooks;
string currentWarningMessage;

struct TIME {
   int seconds;
   int minutes;
   int hours;
};

template <typename T>
void remove(std::vector<T>& v, int index) {
    v.erase(v.begin() + index);
}

template <typename T>
void emptyVector(vector<T> &v)
{
    if(v.size() > 0)
    {
        while(v.size() != 0)
            v.pop_back();
    }
    return;
}

vector<string> tokenize(string s, string del = " ")
{
    vector<string> arr;
    int start = 0;
    int end = s.find(del);
    while (end != -1) {
        arr.push_back(s.substr(start, end - start));
        start = end + del.size();
        end = s.find(del, start);
    }
    arr.push_back(s.substr(start, end - start));
    return arr;
}

void removeBlankLinesFromAFile(const char *file_name)
{   
  ifstream fin(file_name);    
  
  ofstream fout;                
  fout.open("temp.txt", ios::out);
  
  string str;
  while(getline(fin,str))
  { 
    while (str.length()==0 ) 
       getline(fin,str);   
  
    fout<<str<<endl;
  }
  fout.close();  
  fin.close();  
  remove(file_name);        
  rename("temp.txt", file_name);
}

void importFile(vector<string> &array, const char *fileName)
{
    string line; 
    ifstream myfile(fileName); 
    if (myfile.is_open()) 
    {
        while (! myfile.eof() ) 
        {
            getline (myfile,line); 
            array.push_back(line);
        }
        myfile.close(); 
    }
    else cout << "can't open the file"; 
}


void writeToFile(vector<string> &data, const char *fileName)
{
  ofstream outfile;
  outfile.open(fileName, std::ios_base::app);
  for(int i=0; i < data.size(); i++)
    outfile << '\n' << data[i];
}

void filterAvailableBooks()
{
    emptyVector(availableBooks);
    for(int i=0; i < books.size(); i++)
    {
        for(int j=0; j < borrowedBooks.size(); j++)
        {
            vector<string> bookLog = tokenize(borrowedBooks[j]);
            // cout << books[i] << '\n';
            if(bookLog[0] != "" && books[i].find(bookLog[0]) != std::string::npos)
            {
                continue;
            }
            else
            {
                availableBooks.push_back(books[i]);
            }
        }
    }
}


void importFiles(){
  importFile(students, "students.txt");
  importFile(teachers, "teachers.txt");
  importFile(books, "books.txt");
  importFile(borrowedBooks, "borrowedbooks.txt");
}

void addUser(string userName, string userPassword, string userType)
{
    const char *fileName;
    string log = userName + " " + userPassword;
    if(userType == "1")
    {
        fileName = "teachers.txt";
        teachers.push_back(log);
    }
    else
    {
        fileName = "students.txt";
        students.push_back(log);
    }
    vector<string> data;
    data.push_back(log);
    writeToFile(data, fileName);
}

bool isInputCorrect(string input, vector<string> expectedInput)
{
    for(int i=0; i< expectedInput.size(); i++)
        if(input == expectedInput[i])
            return true;
    return false;
}

bool checkIfUserAlreadyPresent(string userName)
{
    for(int i=0; i < students.size(); i++)
    {
        vector<string> studentsData = tokenize(students[i], " ");
        if(userName == studentsData[0])
            return true;
    }
    for(int i=0; i < students.size(); i++)
    {
        vector<string> teachersData = tokenize(teachers[i], " ");
        if(userName == teachersData[0])
            return true;
    }
    return false;
}

bool checkIfBookIsAlreadyBorrowed(string book)
{
    for(int i=0; i < borrowedBooks.size(); i++)
    {
        if(borrowedBooks[i].find(book) != std::string::npos)
        {
            return true;
        }
    }
    return false;
}

bool checkIfBookAlreadyInStock(string bookName, string identificationNumber)
{
    for(int i=0; i < books.size(); i++)
    {
        if(books[i].find(bookName) != std::string::npos || books[i].find(identificationNumber) != std::string::npos)
        {
            cout << "Book Already In Stock!\n";
            return true;
        }
    }
    return false;
}

string formatBookLog(string bookName, string author, string identificationNumber, string category)
{
    return (bookName + " " + author + " " + identificationNumber + " " + category);
}

//book123 kelvin 1235 science
void addBook(string bookName, string author, string identificationNumber, string category)
{
    if(!checkIfBookAlreadyInStock(bookName, identificationNumber))
    {
        string log = formatBookLog(bookName, author, identificationNumber, category);
        books.push_back(log);
        reWriteFile(books, "books.txt");
    }
    return;
}

int convertIntoSeconds(TIME time)
{
    return (time.hours*3600 + time.minutes*60 + time.seconds);
}

void differenceBetweenTimePeriod(struct TIME start,
                                 struct TIME stop,
                                 struct TIME *diff) {
    diff->hours = stop.hours - start.hours;
    diff->minutes = stop.minutes - start.minutes;
    diff->seconds = stop.seconds - start.seconds;
}

TIME convertStringToTime(string time){
    TIME splitTime;
    vector<string> data;
    data = tokenize(time, ":");
    for(int i=0; i < data.size(); i++)
    {
        switch(i)
        {
            case 0:
                splitTime.hours = stoi(data[i]);
                break;
            case 1:
                splitTime.minutes = stoi(data[i]);
                break;
            case 2:
                splitTime.seconds = stoi(data[i]);
                break;
        }
    }
    return splitTime;
}

string convertTimeToString(TIME time){
    return string(to_string(time.hours) + ":" + to_string(time.minutes) + ":" + to_string(time.seconds));
}

TIME returnCurrentTime(){
    TIME currentTime;
    time_t curr_time;
	curr_time = time(NULL);

	tm *tm_local = localtime(&curr_time);
    currentTime.hours = tm_local->tm_hour;
    currentTime.minutes = tm_local->tm_min;
    currentTime.seconds = tm_local->tm_sec;
    return currentTime;
}

int returnSubtractedTime(string previousTime){
    TIME diff;
    TIME currentTime = returnCurrentTime();
    TIME splitPreviousTime = convertStringToTime(previousTime);
    differenceBetweenTimePeriod(currentTime, splitPreviousTime, &diff);
    return convertIntoSeconds(diff);
}

bool checkIfAStringContainsAWord(string sampleString, string word)
{
    return (sampleString.find(word) != std::string::npos);
}

bool isTimeConstraintSatisfied(string rawTime, int timeLimitOfBorrowedBooks)
{
    int time = returnSubtractedTime(rawTime);
    // cout << time << '\n';
    if(time < 0 && time > -timeLimitOfBorrowedBooks)
        return true;
    return false;
}

void clearUserBorrowedBooks()
{
    for(int i=0; i< currentUserBorrowedBooks.size(); i++)
        currentUserBorrowedBooks.pop_back();
}

void addUserBorrowedBooks(string userName, string userType)
{
    string user;
    if(userType == "1")
        user = "teacher";
    else
        user = "student";
    string elementToFind = userName + " " + user;
    for(int i=0; i< borrowedBooks.size(); i++)
    {
        if(checkIfAStringContainsAWord(borrowedBooks[i], elementToFind))
        {
            vector<string> splitString = tokenize(borrowedBooks[i], " ");
            currentUserBorrowedBooks.push_back(splitString);
        }
    }
}

bool checkConstraintsIfAUserBorrowedABook(string userName, string userType)
{
    int countBorrowedBooks = 0, limitOfBorrowedBooks, timeLimitForBorrowedBook;
    if(userType == "1")
    {
        limitOfBorrowedBooks = 5;
        timeLimitForBorrowedBook = 180;
    }
    else
    {
        limitOfBorrowedBooks = 3;
        timeLimitForBorrowedBook = 120;
    }
    clearUserBorrowedBooks();
    addUserBorrowedBooks(userName, userType);
    if(currentUserBorrowedBooks.size() == limitOfBorrowedBooks)
    {
        currentWarningMessage = "Notification: You have borrowed the max limit of books!\n";
        return false;
    }
    for(int i=0; i< currentUserBorrowedBooks.size(); i++)
    {
        if(currentUserBorrowedBooks.size() != 0)
        {
            string borrowedTime = currentUserBorrowedBooks[i][currentUserBorrowedBooks[i].size()-1];
            if(!isTimeConstraintSatisfied(borrowedTime, timeLimitForBorrowedBook))
            {
                currentWarningMessage = "Notification: Your book has exceeded the time limit!\n";
                return false;
            }
        }
    }
    return true;
}

void reWriteFile(vector<string> data, string fileName)
{
    std::ofstream ofs;
    ofs.open(fileName, std::ofstream::out | std::ofstream::trunc);
    for(int i=0; i<data.size(); i++)
        if(i < data.size()-1)
            ofs << data[i] << '\n';
        else
            ofs << data[i];
    ofs.close();
}

void removeLogFromBorrowedBooks(string log)
{
    for(int i=0; i< borrowedBooks.size(); i++)
    {
        if(borrowedBooks[i] == log)
        {
            remove(borrowedBooks, i);
            break;
        }
    }
}

string convertVectorStringToString(vector<string> &data)
{
    string result;
    for(int i=0; i< data.size(); i++)
    {
        if(i < data.size()-1)
            result += (data[i] + " ");
        else
            result += (data[i]);
    }
    return result;
}

void returnABook(string userName, string userType)
{
    string userInput;
    vector<string> userOptions;
    for(int i=0; i< currentUserBorrowedBooks.size(); i++)
    {
        string log = convertVectorStringToString(currentUserBorrowedBooks[i]);
        cout << i << ": " << log << '\n';
        userOptions.push_back(to_string(i));
    }
    cout << "Select a book to return: \n";
    if(userOptions.size() != 0)
    {
        cin >> userInput;
        if(isInputCorrect(userInput, userOptions))
        {
            int index = stoi(userInput);
            string log = convertVectorStringToString(currentUserBorrowedBooks[index]);
            cout << log << '\n';
            remove(currentUserBorrowedBooks, index);
            removeLogFromBorrowedBooks(log);
            reWriteFile(borrowedBooks, "borrowedbooks.txt");
        }
        else
        {
            cout << "Input Out Of Bounds!\n Try Again!\n";
            returnABook(userName, userType);
        }
    }
    else
    {
        cout << "No Options Detected!\n";
    }
    libraryMainPage(userName, userType);
}

string formatLog(string userName, string userType, string bookName)
{
    string user;
    if(userType == "1")
        user = "teacher";
    else
        user = "student";
    string currentTime = convertTimeToString(returnCurrentTime());
    return (bookName + " " + userName + " " + user + " " + currentTime);
}

vector<string> searchItems(string item)
{
    vector<string> searchItems;
    for(int i=0; i < books.size(); i++)
    {
        if(books[i].find(item) != std::string::npos)
        {
            searchItems.push_back(books[i]);
        }
    }
    return searchItems;
}

void borrowABook(string userName, string userType)
{
    string userInput;
    vector<string> userOptions;
    filterAvailableBooks();
    cout << "Available  Books: \n";
    for(int i=0; i< availableBooks.size(); i++)
    {
       cout << i << ": " << availableBooks[i] << '\n';
    }
    cout << "Search a book by title, category, and author: ";
    cin >> userInput;
    for(int i=0; i< availableBooks.size(); i++)
    {
        if(availableBooks[i].find(userInput) != std::string::npos)
        {
            cout << i << ": " << books[i] << '\n';
            userOptions.push_back(to_string(i));
        }
    }
    cout << "Select a book to borrow: \n";
    cin >> userInput;
    if(isInputCorrect(userInput, userOptions))
    {
       vector<string> data = tokenize(availableBooks[stoi(userInput)]);
       if(!checkIfBookIsAlreadyBorrowed(data[0]))
       {
        string log = formatLog(userName, userType, data[0]);
        cout << '\n' << log << '\n';
        currentUserBorrowedBooks.push_back(data);
        borrowedBooks.push_back(log);
        reWriteFile(borrowedBooks, "borrowedbooks.txt");
       }
       else
        cout << "Book is already borrowed!\n";
    }
    else
    {
        cout << "Input Out Of Bounds!\n Try Again!\n";
        borrowABook(userName, userType);
    }
}

void libraryMainPage(string userName, string userType)
{
    vector<string> userOption;
    string userInput;
    if(!checkConstraintsIfAUserBorrowedABook(userName, userType))
    {
        cout << currentWarningMessage;
        if(currentWarningMessage == "Notification: You have borrowed the max limit of books!\n")
            returnABook(userName, userType);
    }

    if(userType == "1")
    {
        cout << "1. Borrow A Book\n2. Return A Book\n3. Main Page\n4. Add Books\n5.Exit\n";
        userOption.push_back("1");
        userOption.push_back("2");
        userOption.push_back("3");
        userOption.push_back("4");
        userOption.push_back("5");
    }
    else
    {
        cout << "1. Borrow A Book\n2. Return A Book\n3. Main Page\n4.Exit\n";
        userOption.push_back("1");
        userOption.push_back("2");
        userOption.push_back("3");
        userOption.push_back("4");
    }
    cout << "Select an option: ";
    cin >> userInput;
    if(isInputCorrect(userInput, userOption))
    {
        switch(stoi(userInput))
        {
            case 1:
                borrowABook(userName, userType);
                break;
            case 2:
                returnABook(userName, userType);
                break;
            case 3:
                mainMenu();
                break;
            case 4:
                if(userType == "1")
                {
                    string bookName, author, identificationNumber, category;
                    cout << "Enter Book Name: ";
                    cin >> bookName;
                    cout << "Enter Author: ";
                    cin >> author;
                    cout << "Enter Identification Number: ";
                    cin >> identificationNumber;
                    cout << "Enter Categroy: ";
                    cin >> category;
                    addBook(bookName, author, identificationNumber, category);
                }
                else
                {
                    exit(0);
                }
                break;
            case 5:
                exit(0);
                break;
        }
    }
    libraryMainPage(userName, userInput);
}

void signUp()
{
    cout << "\nSignUP Page\n";
    vector<string> userOption;
    string inputUserName, inputUserPassword, userType;
    cout << "Enter User Name: ";
    cin >> inputUserName;
    cout << "Enter User Password: ";
    cin >> inputUserPassword;
    cout << "1. Teacher\n 2. Student\n";
    cout << "Select User Type: ";
    cin >> userType;
    userOption.push_back("1");
    userOption.push_back("2");
    if(isInputCorrect(userType, userOption))
    {
        if(!checkIfUserAlreadyPresent(inputUserName)){
            addUser(inputUserName, inputUserPassword, userType);
        }
        else
            cout << "User already present!\n";
        login();
    }
    else
    {
        cout << "Incorrect Option\n";
        signUp();
    }
}

void login()
{
    cout << "\nLogin Page\n";
    vector<string> userOption;
    string inputUserName, inputUserPassword, userType;
    cout << "Enter User Name: ";
    cin >> inputUserName;
    cout << "Enter User Password: ";
    cin >> inputUserPassword;
    cout << "1. Teacher\n 2. Student\n";
    cout << "Select User Type: ";
    cin >> userType;
    userOption.push_back("1");
    userOption.push_back("2");
    if(isInputCorrect(userType, userOption))
    {
        if(checkIfUserAlreadyPresent(inputUserName)){
            libraryMainPage(inputUserName, userType);
        }
        else{
            cout << "User not found!\n";
            cout << "Do you want to sign up?\n";
            cout << "1. Yes\n 2. No\n";
            cout << "Select Option: ";
            cin >> userType;
            if(isInputCorrect(userType, userOption))
            {
                if(userType ==  "1")
                    signUp();
                else
                    login();
            }
            else
            {
                cout << "Incorrect option selected!\n";
                login();
            }
        }
    }
    else
    {
        cout << "Incorrect Option\n";
    }
}

void mainMenu(){
    vector<string> userOption;
    string userInput;
    cout << "1. SignUp\n2. Login\n";
    cout << "Enter Option: ";
    cin >> userInput;
    userOption.push_back("1");
    userOption.push_back("2");
    if(isInputCorrect(userInput, userOption))
    {
        if(userInput == "1")
            signUp();
        else
            login();
    }
    else
    {
        cout << "Incorrect Option\n";
        mainMenu();
    }
}

int main()
{
    importFiles();
    mainMenu();
}