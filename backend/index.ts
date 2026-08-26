/// typescript basic

// first arithmetic operators
let firstName: string = "Min Thiha"; // String type
let lastName: string = "Aung";
let fullName = firstName + "" + lastName; // string concatination
let number1: number = 10; // number type
let isSingle: boolean = true; // bolean type
/// all of these above are explicit type

// inference type
let laptop = "Lenovo";
// can assing every type it automatically define and comfirm that type ( first ) , now it string type without define type exactly because it assign with string type )
// special type
let DellBrand: any = "Dell Brand"; // this assign like explicit but not explicit it let anything to assign not single type
DellBrand = true; // also can assing with bolean value even first type is string beause it define with any ( dyanmic)

// array ( like list in dart as a flutter dev )
let developers: string[] = ["John", "Nathan", "Oliver"];
let designer: string[] = ["Alexa", "Harry", "Thomas"];
let developerSalary: number[] = [6000, 7000, 8000];
let designerSalary: number[] = [5000, 6000, 9000];

// touple ( this is like list<dynamic> in dart )
let developerInfo: [20, "James Thomas", true];

// object
const mobileApp: { type: string; cost: number; isAvailable: boolean } = {
    type: "Ecommerce",
    cost: 15000,
    isAvailable: true,
};

const webSite: { type: string; cost: number; isAvailable: boolean } = {
    type: "Landing Page",
    cost: 3500,
    isAvailable: true,
};

// enum ( like enum in dart )
enum Status {
    failed,
    loading,
    success,
}

// sum function
let num1 = 10;
let num2 = 20;

// void function
function main(): void {
    console.log("Start the Applicatoin");
}

// parameter function ( need to return without void if void included no need to return  )
function sum(a: number, b: number) {
    return a + b;
}

// substract
function substract(a: number, b: number) {
    return a - b;
}

// multiply
function multiply(a: number, b: number) {
    return a * b;
}

// divide
function devide(a: number, b: number) {
    return a / b;
}

// double
function double(value: number) {
    return value * 2;
}

// triple
function triple(value: number) {
    return value * 3;
}
// dynamic
function dynamic(value: number, x: number) {
    return value * x;
}

//
let first = "Type";
let last = "Script";

// return as full name
function concatination(a: string, b: string) {
    return a + " " + b;
}

function printFulName(a: string, b: string): void {
    console.log("${a} ${b}");
}


// type cast 
function typeCastToString( value : string ){
    console.log(value as String);
}