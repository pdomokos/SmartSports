import json
import urllib, httplib
from collections import namedtuple
from datetime import timedelta, datetime
import numpy as np
from collections import namedtuple
import os

Meas = namedtuple('meas', ['datetime', 'code', 'value'])
Unspecified_blood_glucose_measurement1    = 48
Unspecified_blood_glucose_measurement2    = 57
Pre_breakfast_blood_glucose_measurement   = 58
Post_breakfast_blood_glucose_measurement  = 59
Pre_lunch_blood_glucose_measurement       = 60
Post_lunch_blood_glucose_measurement      = 61
Pre_supper_blood_glucose_measurement      = 62
Post_supper_blood_glucose_measurement     = 63
Pre_snack_blood_glucose_measurement       = 64
days=50
prebreakfast = np.random.normal(9.458, 3.923, days)
prebreakfast2 = np.random.normal(7.953, 3.387, days)
prelunch = np.random.normal(7.84, 3.53, days)
presupp = np.random.normal(8.958, 3.687, days)
presleep = np.random.normal(8.342, 4.02, days)
timediff = np.random.normal(0, 20*60, days*4)

def gen_bg(data):
    day = datetime.now()-timedelta(days)
    end_date = datetime.now()
    gdays = []

    while day <= end_date:
        if findforday(day,data):
            print 'at least one data exist for day'
        else:
            gdays.extend(generateforday(day))
        day += timedelta(days=1)
    return gdays

def findforday(day,data):
    b = str(day.strftime("%Y-%m-%d"))
    for jsonobj in data:
        a = datetime.strptime(jsonobj['date'], '%Y-%m-%dT%H:%M:%S.000+02:00').strftime("%Y-%m-%d")
        if a == b:
           return True
    return False

def generateforday(actual):

    if(actual.date() == datetime.today().date()):
        bgtime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=8, seconds=timediff[np.random.randint(1, days*4)])
        if actual > bgtime:
            res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Pre_breakfast_blood_glucose_measurement, prebreakfast[np.random.randint(1, days)])
            yield res
        bgtime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=12, seconds=timediff[np.random.randint(1, days*4)])
        if actual > bgtime:
            res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Pre_lunch_blood_glucose_measurement, prelunch[np.random.randint(1, days)])
            yield res
        bgtime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=18, seconds=timediff[np.random.randint(1, days*4)])
        if actual > bgtime:
            res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Pre_supper_blood_glucose_measurement, presupp[np.random.randint(1, days)])
            yield res
        bgtime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=21, seconds=timediff[np.random.randint(1, days*4)])
        if actual > bgtime:
            res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Unspecified_blood_glucose_measurement1, presleep[np.random.randint(1, days)])
            yield res
    else:
        bgtime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=8, seconds=timediff[np.random.randint(1, days*4)])
        res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Pre_breakfast_blood_glucose_measurement, prebreakfast[np.random.randint(1, days)])
        yield res
        bgtime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=12, seconds=timediff[np.random.randint(1, days*4)])
        res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Pre_lunch_blood_glucose_measurement, prelunch[np.random.randint(1, days)])
        yield res
        bgtime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=18, seconds=timediff[np.random.randint(1, days*4)])
        res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Pre_supper_blood_glucose_measurement, presupp[np.random.randint(1, days)])
        yield res
        bgtime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=21, seconds=timediff[np.random.randint(1, days*4)])
        res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Unspecified_blood_glucose_measurement1, presleep[np.random.randint(1, days)])
        yield res

def post_resource(urlbase, resource_path, headers, res):
    conn = httplib.HTTPConnection(urlbase, 3000)
    body = {'measurement[source]': 'demo', 
            'measurement[meas_type]': 'blood_sugar', 
            'measurement[date]': res.datetime, 
            'measurement[blood_sugar]': res.value,
            'measurement[blood_sugar_time]': res.code}
            
    conn.request("POST", resource_path, urllib.urlencode(body), headers)
    post_resp = conn.getresponse()
    if post_resp.status != httplib.OK:
        print 'fail, status='
        print post_resp.status
    else:
        params = json.loads(post_resp.read())
        if params['ok']:
            print 'added, '+str(params['id'])
        else:
            print 'failed, '+params['msg']

if __name__ == "__main__":
    params = None
    with open(os.environ['HOME']+'/smartdiab.json', 'r') as f:
        params = json.load(f)

    urlbase = 'localhost'
    token_path = '/oauth/token'
    profile_path = '/api/v1/profile'
    req_params = {'grant_type': 'password',
                  'username': params['username'],
                  'password': params['password'],
                  'client_id': params['smartdiab_appid']
                  }

    conn = httplib.HTTPConnection(urlbase, 3000)
    conn.request("POST", token_path, urllib.urlencode(req_params))
    resp = conn.getresponse()
    if resp.status==httplib.OK:
        resp_json = json.loads(resp.read())
        token = resp_json['access_token']
        conn.close()
        headers = {"Authorization": "Bearer "+token}
        conn = httplib.HTTPConnection(urlbase, 3000)
        conn.request("GET", profile_path, "", headers)
        print profile_path
        prf_resp = conn.getresponse()
        if prf_resp.status == httplib.OK:
            profile = json.loads(prf_resp.read())
            #print "user_id="+str(profile['id'])+' token='+token
            post_resource_path = "/api/v1/users/"+str(profile['id'])+"/measurements"
            resource_path = post_resource_path + "?days="+str(days)+"&limit=300"
            conn = httplib.HTTPConnection(urlbase, 3000)
            conn.request("GET", resource_path, "", headers)
            get_resp = conn.getresponse()
            if get_resp.status != httplib.OK:
                print 'fail, status='
                print get_resp.status
            else:
                params = json.loads(get_resp.read())
                for res in gen_bg(params):
                    post_resource(urlbase, post_resource_path, headers, res)
