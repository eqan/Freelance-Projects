import Member from './class Member.js';
import { question } from 'readline-sync';

export default class MemberGroup {
    constructor() {
        this.memberGroup = [];
    }

    newMember(name, membershipType, dateJoined, dateOfBirth, pointsEarned) {
        this.memberGroup.push(new Member(name, membershipType, dateJoined, dateOfBirth, pointsEarned))
    }

    getMembers() {
        for (let i = 0; i < this.memberGroup.length; i++) {
            console.log("Name : " + this.memberGroup[i].name)
            console.log("Membership Type : " + this.memberGroup[i].membershipType)
            console.log("Date Joined : " + this.memberGroup[i].datejoined)
            console.log("Date of Birth : " + this.memberGroup[i].birth)
            console.log("Points Earned : " + this.memberGroup[i].points)
            console.log("\n")
        }
    }
    getNumberOfMembers() {
        return this.memberGroup.length
    }
    getMemberAt(index) {
        return this.memberGroup[index]
    }
    searchMember(searchMember) {
        for (let i = 0; i < this.getNumberOfMembers(); i++) {
            if (searchMember == this.getMemberAt(i).name) {
                this.getMemberAt(i).printMember()
                return
            }


        }
        console.log("Member does not exist.")
    }

    getAgeInDays(date1, date2)
    {
        return parseInt((date1 - date2) / (1000 * 60 * 60 * 24), 10); 
    }

    getyoungestAndOldestMember(){

        let dates=[];
        if(this.getNumberOfMembers() > 1)
        {
            for (let i = 0; i < this.getNumberOfMembers(); i++) {
                let birth = new Date(this.getMemberAt(i).birth);
                dates.push(birth);
                }
            let youngestMemberBirth = new Date(Math.max.apply(null,dates));
            let oldestMemberBirth = new Date(Math.min.apply(null,dates));
            let youngestMember = "";
            let oldestMember = "";

            for (let i = 0; i < this.getNumberOfMembers(); i++) {
                let birth = new Date(this.getMemberAt(i).birth);
                if(birth.getTime() == youngestMemberBirth.getTime())
                {
                    youngestMember = this.getMemberAt(i).name;
                }
                else if(birth.getTime() == oldestMemberBirth.getTime())
                {
                    oldestMember = this.getMemberAt(i).name;
                }
                }
            return ({'Oldest': oldestMember, 'Youngest': youngestMember})
        }
        return null;
        }
    
    getMembersWithHighestAndLowestPoints()
    {
        let points=[];
        if(this.getNumberOfMembers() > 1)
        {
            for (let i = 0; i < this.getNumberOfMembers(); i++) {
                points.push(this.getMemberAt(i).points)
                }
            let lowestPoints = Math.min.apply(null,points);
            let highestPoints = Math.max.apply(null,points);
            let lowestPointMember = "";
            let highestPointMember = "";

            for (let i = 0; i < this.getNumberOfMembers(); i++) {
                let point = this.getMemberAt(i).points;
                if(point == lowestPoints)
                {
                    lowestPointMember = this.getMemberAt(i).name;
                }
                else if(point == highestPoints)
                {
                    highestPointMember = this.getMemberAt(i).name;
                }
                }
            return ({'Lowest': lowestPointMember, 'Highest': highestPointMember})
        }
        return null;

    }

    searchMemberType(type) {
        let members = [];
        for (let i = 0; i < this.getNumberOfMembers(); i++) {
            if (type == this.getMemberAt(i).membershipType) {
                members.push(this.getMemberAt(i).name)
            }
        }
        return members;
    }

    displayNumberOfMemberShipGroups()
    {
        let count = {'Ruby': 0, 'Platinum': 0, 'Gold': 0, 'Diamond': 0};
        if(this.getNumberOfMembers() > 1)
        {
            for (let i = 0; i < this.getNumberOfMembers(); i++)
             {
                let membershipType = this.getMemberAt(i).membershipType
                if(count[`${membershipType}`] == null)
                    count[`${membershipType}`] = 1;
                else
                    count[`${membershipType}`]++;
             }
        }
        for (const key in count) {
            console.log(`${key}: ${count[key]}`);
        }
    }

    displayTotalPointsOfMemberShipGroups()
    {
        let count = {'Ruby': 0, 'Platinum': 0, 'Gold': 0, 'Diamond': 0};
        if(this.getNumberOfMembers() > 1)
        {
            for (let i = 0; i < this.getNumberOfMembers(); i++)
             {
                let membershipType = this.getMemberAt(i).membershipType
                let point = this.getMemberAt(i).points;
                if(count[`${membershipType}`] == null)
                    count[`${membershipType}`] = point;
                else
                    count[`${membershipType}`]+=point;
             }
        }
        for (const key in count) {
            console.log(`${key}: ${count[key]}`);
        }
    }


    addMember(name) {
        do {
            if (name == this.memberGroup[0].name || name == this.memberGroup[1].name || name == this.memberGroup[2].name || name == this.memberGroup[3].name || name == this.memberGroup[4].name) {
                console.log("Member's name exists in the database. Please enter a new name.")
                var name = question("Please enter member's name: ");
            }
            else {
                var birth = question("Please enter date of birth: ")
                var date1 = new Date();
                var todayMth = date1.toLocaleString("default", {month: "short"});
                var todayDate = date1.getDate() + " " + todayMth + " " + date1.getFullYear()
                this.memberGroup.push(new Member(name,"Ruby",todayDate, birth, 0));
                
            }
        }
        while (name == this.memberGroup[0].name || name == this.memberGroup[1].name || name == this.memberGroup[2].name || name == this.memberGroup[3].name || name == this.memberGroup[4].name)
    }
}