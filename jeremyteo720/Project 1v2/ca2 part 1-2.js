// Name : Jacob Teo Shao Jie
// Class : DCITP/FT/1A/06
// Adm no. : 2238463

//This program uses the array function as well as the for loop 
//and else if loop to enable it to work
import MemberGroup from './class MemberGroup.js';
import { question } from "readline-sync";

// These arrays contain the members' information about their personal details as well as number of points
// and which level of membership they are at 

var memberGroup = new MemberGroup();

// Date must be in DD-MM-YY
memberGroup.newMember("Leonardo", "Gold", "2019/12/1", "1980/1/1", 1400);
memberGroup.newMember("Catherine", "Ruby", "2020/1/14", "1985/10/28", 250);
memberGroup.newMember("Luther", "Gold", "2020/4/29", "1992/3/16", 3350);
memberGroup.newMember("Bruce", "Diamond", "2020/6/3", "1994/3/18", 40200);
memberGroup.newMember("Amy", "Gold", "2020/6/5", "2000/5/31", 500);

let str = "\n";
console.log("Welcome to XYZ Membership Loyalty Programme!");
var userInput = question("Please enter your name: ")
console.log(str);

// This line of code is asking for the input of the user's name as a question prompt

function main()
{
 do{ 
  console.log("\n" + "Hi " + userInput + ", please select your choice: ")
  console.log("\t" + "1. Display all member's information")
  console.log("\t" + "2. Display member information")
  console.log("\t" + "3. Add new member")
  console.log("\t" + "4. Update points earned")
  console.log("\t" + "5. Statistics")
  console.log("\t" + "6. Exit")
  const choiceInput = question("\t" + ">> ")
  var choice = parseFloat(choiceInput)
 
  // These lines of code displays the options that are available after the user has input their name



  switch (choice) {
    case 1:
      console.log(str);
      memberGroup.getMembers()
      break;
    case 2:
      var searchMember = question("Please enter member's name: ");
      searchMember = searchMember.toLowerCase();
      searchMember = searchMember.charAt(0).toUpperCase() + searchMember.slice(1);
      memberGroup.searchMember(searchMember)
      console.log(str);
      break;
    case 3:
      var name = question("Please enter member's name: ");
      //conversion of name into proper casing
      name = name.toLowerCase()
      name = name.charAt(0).toUpperCase() + name.slice(1);
      memberGroup.addMember(name)
      break;
    case 4:
      var name = question("Please enter member's name: ")
      name = name.toLowerCase()
      name = name.charAt(0).toUpperCase() + name.slice(1);
      break;
    case 5:
      do {
        console.log("\t\t" + "Please Select an option from the sub-menu:")
        console.log("\t\t" + "1. Display names of (all) a certain type of members only.")
        console.log("\t\t" + "2. Display the name of the youngest and oldest member in the system.")
        console.log("\t\t" + "3. Display the name of the members with the highest and lowest points earned.")
        console.log("\t\t" + "4. Display total number of members in each membership type.")
        console.log("\t\t" + "5. Display total points in each membership type.")
        console.log("\t\t" + "6. Return to main menu.")
        const choiceInput = question("\t" + ">> ")
        var choice = parseFloat(choiceInput)
        switch(choice)
        {
            case 1:
              const membershipType = question("Enter Membership Type: ")
              const _members = memberGroup.searchMemberType(membershipType);
              if(_members.length > 0)
              {
                  console.log(`Member(s) of membership type ${membershipType}:`)
                  for(let i=0; i< _members.length; i++) 
                  {
                    console.log(`${i}: ${_members[i]}`);
                  }
              }
              else
              {
                  console.log("Please enter a valid membership type.")
              }
              break;
            case 2:
              let members1 = memberGroup.getyoungestAndOldestMember();
              console.log(`Youngest Member: ${members1['Youngest']}`)
              console.log(`Oldest Member: ${members1['Oldest']}`)
              break;
            case 3:
              let members2 = memberGroup.getMembersWithHighestAndLowestPoints();
              console.log(`Highest Member: ${members2['Highest']}`)
              console.log(`Lowest Member: ${members2['Lowest']}`)
              break;
            case 4:
              memberGroup.displayNumberOfMemberShipGroups();
              break;              
            case 5:
              memberGroup.displayTotalPointsOfMemberShipGroups();
              break;              
            case 6:
              main();
              break;
            default:
              console.log("Please enter a valid input.")
              break;
            }
      }while(choice != 6)
      break;
    case 6:
      console.log("Thank you & goodbye!")
      break;
    default:
      console.log("Please enter a valid input.")
      break;
  } 

  // These else if functions are used if the user opts to select any choice besides the first choice
  // as there is only the first choice that has information, whereas the second and third choices are 
  // still under development, and the fourth option exits the user from the programmme
 }while (choice != 6);
}


main();