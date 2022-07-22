// Name : Jacob Teo Shao Jie
// Class : DCITP/FT/1A/06
// Adm no. : 2238463

//This program uses the array function as well as the for loop 
//and else if loop to enable it to work

import MemberGroup from './class MemberGroup.js';
import {question} from "readline-sync";

// These arrays contain the members' information about their personal details as well as number of points
// and which level of membership they are at 

var memberGroup = new MemberGroup();

memberGroup.newMember("Leonardo","Gold","1 Dec 2019","1 Jan 1980",1400 );
memberGroup.newMember("Catherine","Ruby","14 Jan 2020","28 Oct 1985",250);
memberGroup.newMember("Luther","Gold","29 Apr 2020","16 Mar 1992",3350 );
memberGroup.newMember("Bruce","Diamond","3 Jun 2020", "18 Mar 1994",40200);
memberGroup.newMember("Luther","Gold","29 Apr 2020","16 Mar 1992",3350 );
memberGroup.newMember("Amy","Ruby", "5 Jun 2020","31 May 2000",500);

let str = "\n";
console.log("Welcome to XYZ Membership Loyalty Programme!");
var userInput = question("Please enter your name: ")
console.log(str);

// This line of code is asking for the input of the user's name as a question prompt

for (let x = 0; x < 2; x++) {
  console.log("\n" + "Hi " + userInput + ", please select your choice: ")
  console.log("\t" + "1. Display all member's information")
  console.log("\t" + "2. Display member information")
  console.log("\t" + "3. Add new member")
  console.log("\t" + "4. Update points earned")
  console.log("\t" + "5. Statistics")
  console.log("\t" + "6. Exit")
  const choiceInput = question("\t" + ">> ")
  const choice = parseFloat(choiceInput)

  // These lines of code displays the options that are available after the user has input their name



  if (choice == 1) {
    console.log(str);
    memberGroup.getMembers();
    x = 0;
    continue;
  } else if (choice == 2) {
    console.log("Sorry, work in progress!")
    console.log(str);
    x = 0;
    continue;
  } else if (choice == 3) {
    console.log(str);
    x = 0;
    continue;
  } else if (choice == 4) {

  } else if (choice == 5) {

  } else if (choice == 6) {
    console.log("Thank you & goodbye!")
    break;
  } else {
    console.log("Please enter a valid input.")
    x = 0;
    continue;
  }
  // These else if functions are used if the user opts to select any choice besides the first choice
  // as there is only the first choice that has information, whereas the second and third choices are 
  // still under development, and the fourth option exits the user from the programmme

}