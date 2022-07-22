import Member from './class Member.js';

export default class memberGroup{
    constructor(){
    this.memberGroup = [];
    }

    newMember(name, membership, dateJoined, dateOfBirth, pointsEarned)
    {
        this.memberGroup.push(new Member(name, membership, dateJoined, dateOfBirth, pointsEarned))
    }

    getMembers()
    {
        for (let i = 0; i < this.memberGroup.length; i++)
        {
            console.log("Name : " + this.memberGroup[i].name)
            console.log("Membership Type : " + this.memberGroup[i].membertype)
            console.log("Date Joined : " + this.memberGroup[i].datejoined)
            console.log("Date of Birth : " + this.memberGroup[i].birth)
            console.log("Points Earned : " + this.memberGroup[i].points)
        }
    }
}