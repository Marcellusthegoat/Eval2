from flask_pymongo import PyMongo
from flask_cors import CORS
from werkzeug.security import generate_password_hash,check_password_hash
from flask import Flask,request,jsonify
from flask_jwt_extended import (
JWTManager,
create_access_token,
jwt_required,
get_jwt_identity
) 
from datetime import timedelta



app = Flask(__name__)

app.config["MONGO_URI"] ="mongodb+srv://marcellusfieldridley:12345@cluster0.kxuyvqi.mongodb.net/billSplitter"
app.config["SECRET_KEY"] = "hasdGEASDFfSfgx"
app.config["JWT_SECRET_KEY"] = "Guye9ySHD"

CORS(app)
mongo = PyMongo(app)
jwt = JWTManager(app)
mdbUser = mongo.db.users
mdbBills = mongo.db.bills

@app.route("/signUp", methods = ["POST"])
def signUp():
    data = request.get_json()
    username = data["username"]
    password = data["password"]
    confirmPassword = data["confirmPassword"]
    print(username,password,confirmPassword)

    users = list(mdbUser.find({"username":username}))
    print(len(users))
    if len(users) == 0:
        if password == confirmPassword:
            print("inserted")
            mdbUser.insert_one({"username":username,"password":generate_password_hash(password)})
            accessToken = create_access_token(identity=username,expires_delta=timedelta(minutes=10))
            return jsonify({"message":"Succesfully Registered","token":accessToken}),201
        return jsonify({"message":"Password is not the same as confirm password"}),422
    return jsonify({"message":"User Already Exists"}),401
@app.route("/login", methods = ["POST"])
def login():
    data = request.get_json()
    username = data["username"]
    password = data["password"]
    print(username,password)

    users = mdbUser.find_one({"username":username})
    print(users)
    if users == None:
        return jsonify({"message":"User Doesnt Exist"}),401
    print("user Exists")
    
    if check_password_hash(password,users["password"]):
        print("creates")

        accessToken = create_access_token(identity=username,expires_delta=timedelta(minutes=10))
        return jsonify({"message":"Succesfully Logged in","token":accessToken}),201
    return jsonify({"message":"Incorrect password"}),422

@app.route("/split", methods = ["POST"])
def splitBill():
    print("started")
    data = request.get_json()
    peopleEating = data["peopleEating"]
    finalBill = data["finalBill"]
    tipPercent = data["tipPercent"]
    if peopleEating != None and finalBill != None and tipPercent != None and peopleEating != 0:
        print("continuing")
        finalBill = (int(finalBill)*float(tipPercent)) + int(finalBill)
        indiviualCost = round((finalBill/int(peopleEating)),2)
        dataToBeReturned = {"finalBill":finalBill,"costPerPerson":indiviualCost}
        print("end")
        return jsonify(dataToBeReturned),200
    else:
        print("error")
        return jsonify({"message":"There was an error"}),401

@app.route("/bills", methods = ["POST","GET"])
def bills():
    if request.method == "POST":
        print("bills")
        data = request.get_json()
        trueFinalCost = data["trueFinalCost"]
        costForEach = data["costForEach"]
        numOfPeople = data["numOfPeople"]
        userToken = data["user"]

        print(trueFinalCost,costForEach,numOfPeople,userToken)

        mdbBills.insert_one({"token":userToken,"costForEach":costForEach,"numOfPeople":numOfPeople,"trueFinalCost":trueFinalCost})
        return jsonify({"message":"success"}),200

if __name__ == '__main__':
    app.debug = True
    app.run(host='0.0.0.0',port=5000)
