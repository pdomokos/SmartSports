import json
from urllib.request import Request, urlopen
from urllib.parse import urlencode
from urllib.error import URLError, HTTPError
from collections import namedtuple
from datetime import timedelta, datetime
from datetime import datetime, date, time
import numpy as np
from collections import namedtuple
import os, sys
from os.path import expanduser
from dateutil.tz import tzlocal
import argparse

class Medication(namedtuple('medication', ['date', 'name', 'amount'])):
    def toDict(self):
        val =  {'medication[source]': 'smartdiab',
            'medication[date]': self.date.strftime('%Y-%m-%d %H:%M:%S'),
            'medication[amount]': self.amount,
            'medication[name]': self.name
        }
        return val
        
class Diet(namedtuple('diet', ['date', 'name', 'amount'])):
    def toDict(self):
        val =  {'diet[source]': 'smartdiab',
            'diet[date]': self.date.strftime('%Y-%m-%d %H:%M:%S'),
            'diet[amount]': self.amount,
            'diet[name]': self.name
        }
        return val
        
class Lifestyle(namedtuple('lifestyle', ['start_time', 'end_time', 'name', 'amount'])):
    def toDict(self):
        val =  {'lifestyle[source]': 'smartdiab',
            'lifestyle[start_time]': self.start_time.strftime('%Y-%m-%d %H:%M:%S'),
            'lifestyle[end_time]': self.end_time.strftime('%Y-%m-%d %H:%M:%S'),
            'lifestyle[amount]': self.amount,
            'lifestyle[name]': self.name
        }
        return val
        
class Activity(namedtuple('activity', ['start_time', 'end_time', 'name', 'intensity'])):
    def toDict(self):
        val =  {'activity[source]': 'smartdiab',
            'activity[start_time]': self.start_time.strftime('%Y-%m-%d %H:%M:%S'),
            'activity[end_time]': self.end_time.strftime('%Y-%m-%d %H:%M:%S'),
            'activity[intensity]': self.intensity,
            'activity[name]': self.name
        }
        return val
        
class Meas(namedtuple('meas', ['datetime', 'sys', 'dia', 'pulse', 'blood_sugar', 'weight', 'waist', 'blood_sugar_note', 'stress_amount',  'blood_sugar_time'])):
    def toDict(self):
        val =  {'measurement[source]': 'smartdiab',
            'measurement[date]': self.datetime.strftime('%Y-%m-%d %H:%M:%S'),
        }
        if self.sys!=None:
            val['measurement[meas_type]'] = 'blood_pressure'
            val['measurement[systolicbp]'] = self.sys
        if self.dia!=None:
            val['measurement[diastolicbp]'] = self.dia
        if self.pulse!=None:
            val['measurement[pulse]'] = self.pulse
        if self.blood_sugar!=None:
            val['measurement[blood_sugar]'] = self.blood_sugar
            val['measurement[meas_type]'] = 'blood_sugar'
        if self.blood_sugar_note!=None:
            val['measurement[blood_sugar_note]'] = self.blood_sugar_note
        if self.blood_sugar_time!=None:
            val['measurement[blood_sugar_time]'] = self.blood_sugar_time
        if self.weight!=None:
            val['measurement[weight]'] = self.weight
            val['measurement[meas_type]'] = 'weight'
        if self.waist!=None:
            val['measurement[waist]'] = self.waist
            val['measurement[meas_type]'] = 'waist'
        if self.stress_amount!=None:
            val['measurement[stress_amount]'] = self.stress_amount
        return val
Meas.__new__.__defaults__ = (None,) * len(Meas._fields)

class Connection:
    def __init__(self, url, username, password):
        self.url = url
        self.tokenOk = False
        self.profileOk = False
        self.getToken(username, password)
        if self.tokenOk:
            self.getProfile()

    def send(self, req):
        try:
            resp = urlopen(req)
            return resp.read().decode('utf8')
        except URLError as e:
            print("error during post: {:d}, {:s}".format(e.code, e.reason))
            return None
        except HTTPError as e:
            print("httperror during post: {:d}, {:s}".format(e.code, e.read().decode('utf8')))
            return None
            
    def getToken(self, username, password):
        token_path = '/oauth/token'
        profile_path = '/api/v1/profile'
        req_params = {'grant_type': 'password',
                      'username': username,
                      'password': password
                      }
        req = Request(self.url+token_path, urlencode(req_params).encode('utf8'), method="POST")
        resp = self.send(req)
        if resp != None:
            respJson = json.loads(resp)
            self.token = respJson['access_token']
            self.tokenOk = True
            
    def getProfile(self):
        profile_path = '/api/v1/profile'
        headers = {"Authorization": "Bearer "+self.token}
        req = Request(self.url+profile_path, None, headers)

        profileResp = self.send(req)
        if profileResp != None:
            self.profile = json.loads(profileResp)
            self.profileOk = True

    def post(self, resource, data):
        resourcePath = self.url+"/api/v1/users/"+str(self.profile['id'])+"/"+resource
        headers = {"Authorization": "Bearer "+self.token}
        req = Request(resourcePath, urlencode(data).encode('utf8'), headers, method="POST")
        resp = self.send(req)
        return resp
        
    def get(self, resource, query):
        resourcePath = self.url+"/api/v1/users/"+str(self.profile['id'])+"/"+resource+query
        headers = {"Authorization": "Bearer "+self.token}
        req = Request(resourcePath, None, headers, method="GET")
        resp = self.send(req)
        return resp
        
def genSleep(rest, currDateTime):
    midnight = datetime(currDateTime.year, currDateTime.month, currDateTime.day)
    startTime = midnight-timedelta(hours=2)+timedelta(minutes=int(np.random.normal(40, 20)))
    endTime = startTime+timedelta(minutes=int(np.random.normal(60*8, 60)))
    lstyle = Lifestyle(startTime, endTime, 'sleep', 1)
    rest.post('lifestyles', lstyle.toDict())
    return endTime
    
def getBg():
    bg = 0
    while bg<2:
        bg = np.random.normal(5, 2)+1.5
    spike = np.random.uniform(8)
    if(spike<1):
        bg += np.random.uniform(10)+5
    return bg
    
def genBloodGlucose(rest, currDateTime):
    bgTime = currDateTime+timedelta(minutes=int(np.random.normal(30, 10)))
    bgValue = round(getBg(), 2)
    meas = Meas(bgTime, blood_sugar = bgValue, stress_amount = 1, blood_sugar_time = 0)
    rest.post('measurements', meas.toDict())
    if bgValue > 6:
        medtime = bgTime+timedelta(minutes=int(np.random.uniform(10)))
        med = Medication(medtime, 3, np.random.choice(5)+1)
        rest.post('medications', med.toDict())
    return bgTime
    
def genBloodPressure(rest, currDateTime):
    bpTime = currDateTime+timedelta(minutes=int(np.random.normal(30, 10)))
    
    meas = Meas(bpTime, sys = int(np.random.normal(120, 10)), dia=int(np.random.normal(80, 10)), pulse=int(np.random.normal(70, 10)))
    rest.post('measurements', meas.toDict())
    return bpTime
    
def genActivity(rest, currDateTime, name):
    startTime = currDateTime+timedelta(minutes=int(np.random.uniform(10)+30))
    endTime = startTime+timedelta(minutes=int(np.random.normal(40, 10)))
    act = Activity(startTime, endTime, name, 1)
    rest.post('activities', act.toDict())
    return endTime

def genDiet(rest, currDateTime, name):
    foodTime = currDateTime+timedelta(minutes=int(np.random.normal(20, 5)))
    
    food = Diet(foodTime, name, 2)
    rest.post('diets', food.toDict())
    return foodTime
    
def genData(rest, currDateTime):
    midnight = datetime(currDateTime.year, currDateTime.month, currDateTime.day)
    
    sleepEnd = genSleep(rest, currDateTime)
    bgTime1 = genBloodGlucose(rest, sleepEnd)
    actEnd = genActivity(rest, bgTime1, 'running')
    bpTime = genBloodPressure(rest, actEnd+timedelta(minutes=30))
    bgTime2 = genBloodGlucose(rest, actEnd)
    breakfastTime = genDiet(rest, bgTime2, 'breakfast')
    lunchTime = midnight+timedelta(hours=12)+timedelta(minutes=int(np.random.normal(30, 15)))
    bgTime3 = lunchTime-timedelta(minutes=int(np.random.uniform(15)))
    genBloodGlucose(rest, bgTime3)
    cyclingTime = midnight+timedelta(hours=17)+timedelta(minutes=int(np.random.normal(30, 15)))
    genActivity(rest, cyclingTime, 'bicycling')
    genDiet(rest, lunchTime, 'lunch')
    dinnerTime = midnight+timedelta(hours=19)+timedelta(minutes=int(np.random.normal(30, 15)))
    genDiet(rest, dinnerTime, 'dinner')
    genBloodGlucose(rest, dinnerTime)
    
if __name__ == "__main__":
    fmt = "%Y-%m-%d"

    parser = argparse.ArgumentParser(description='Generate blood glucose data.')
    parser.add_argument('--start', nargs='?', help='starting date', default=datetime.now().strftime(fmt))
    parser.add_argument('--config', nargs='?', help='config, e.g. production. default=development', default='development')
    parser.add_argument('--days', nargs='?', help='number of days to generate', default=1)
    args = parser.parse_args()
    print(args)
    
    currDateTime = datetime.strptime(args.start, fmt)
    print("generateing data for: {}, config={}, days={}".format(args.start, args.config, args.days))

    home = expanduser("~")
    with open(os.path.join(home, ".smartdiab.json")) as f:
        params = json.load(f)
    restConn = Connection(params[args.config]['url'], params[args.config]['user'], params[args.config]['password'])

    for i in range(int(args.days)):
        print("generating for: {}", currDateTime.strftime(fmt))
        genData(restConn, currDateTime)
        currDateTime = currDateTime+timedelta(days=1)
