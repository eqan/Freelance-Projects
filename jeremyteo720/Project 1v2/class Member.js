export default class Member {
    constructor(name, membershipType, dateJoined, dateofBirth, pointsEarned) {
        this.name = name
        this.membershipType = membershipType
        this.datejoined = dateJoined
        this.birth = dateofBirth
        this.points = pointsEarned
    }
    printMember() {
        console.log("\nName: " + this.name)
        console.log("Membership Type : " + this.membershipType)
        console.log("Date Joined: " + this.datejoined)
        console.log("Date of Birth: " + this.birth)
        console.log("Points Earned: " + this.points)
    }
    

}