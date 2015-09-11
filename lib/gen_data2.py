import json
import urllib, httplib
from collections import namedtuple
from datetime import timedelta, datetime
import numpy as np
from collections import namedtuple
import os

Meas = namedtuple('meas', ['datetime', 'code', 'value'])
Meas_ht = namedtuple('meas', ['datetime', 'svalue', 'dvalue', 'pulse'])
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


prebreakfast_svals = np.random.normal(110, 15, days)
prelunch_svals = np.random.normal(120, 12, days)
presupp_svals = np.random.normal(120, 16, days)
presleep_svals = np.random.normal(110, 12, days)

prebreakfast_dvals = np.random.normal(80, 7, days)
prelunch_dvals = np.random.normal(80, 10, days)
presupp_dvals = np.random.normal(85, 10, days)
presleep_dvals = np.random.normal(78, 6, days)

prebreakfast_pulses = np.random.normal(66, 8, days)
prelunch_pulses = np.random.normal(100, 10, days)
presupp_pulses = np.random.normal(80, 7, days)
presleep_pulses = np.random.normal(64, 7, days)

def gen_data(data, type):
    day = datetime.now()-timedelta(days)
    end_date = datetime.now()
    gdays = []

    while day <= end_date:
        if findforday(day,data,type):
            print 'at least one data exist for day'
        else:
            if type == "blood_sugar":
                gdays.extend(generateforday_bg(day))
            elif type == "blood_pressure":
                gdays.extend(generateforday_ht(day))
        day += timedelta(days=1)
    return gdays


def findforday(day,data, type):
    b = str(day.strftime("%Y-%m-%d"))
    for jsonobj in data:
        a = datetime.strptime(jsonobj['date'], '%Y-%m-%dT%H:%M:%S.000+02:00').strftime("%Y-%m-%d")
        if(a == b and jsonobj['meas_type'] == type):
           return True
    return False

def generateforday_bg(actual):
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

def generateforday_ht(actual):
    httime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=8, seconds=timediff[np.random.randint(1, days*4)])
    res = Meas_ht(httime.strftime("%Y-%m-%d %H:%M:%S"), prebreakfast_svals[np.random.randint(1, days)], prebreakfast_dvals[np.random.randint(1, days)], prebreakfast_pulses[np.random.randint(1, days)])
    yield res
    httime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=12, seconds=timediff[np.random.randint(1, days*4)])
    res = Meas_ht(httime.strftime("%Y-%m-%d %H:%M:%S"), prelunch_svals[np.random.randint(1, days)], prelunch_dvals[np.random.randint(1, days)], prelunch_pulses[np.random.randint(1, days)])
    yield res
    httime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=18, seconds=timediff[np.random.randint(1, days*4)])
    res = Meas_ht(httime.strftime("%Y-%m-%d %H:%M:%S"), presupp_svals[np.random.randint(1, days)], presupp_dvals[np.random.randint(1, days)], presupp_pulses[np.random.randint(1, days)])
    yield res
    httime = datetime(actual.year, actual.month, actual.day)+timedelta(hours=21, seconds=timediff[np.random.randint(1, days*4)])
    res = Meas_ht(httime.strftime("%Y-%m-%d %H:%M:%S"), presleep_svals[np.random.randint(1, days)], presleep_dvals[np.random.randint(1, days)], presleep_pulses[np.random.randint(1, days)])
    yield res


def post_resource_bg(urlbase, resource_path, headers, res):
    body = {'measurement[source]': 'demo', 
            'measurement[meas_type]': 'blood_sugar', 
            'measurement[date]': res.datetime, 
            'measurement[blood_sugar]': res.value,
            'measurement[blood_sugar_time]': res.code}
    get_response(urlbase, resource_path, body, headers)

def post_resource_ht(urlbase, resource_path, headers, res_ht):
    body = {'measurement[source]': 'demo',
            'measurement[meas_type]': 'blood_pressure',
            'measurement[date]': res_ht.datetime,
            'measurement[systolicbp]': res_ht.svalue,
            'measurement[diastolicbp]': res_ht.dvalue,
            'measurement[pulse]': res_ht.pulse}
    get_response(urlbase, resource_path, body, headers)

def get_response(urlbase, resource_path, body, headers):
    conn = httplib.HTTPConnection(urlbase, 3000)
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
            resource_path = post_resource_path + "?days="+str(days)+"&limit=500"
            conn = httplib.HTTPConnection(urlbase, 3000)
            conn.request("GET", resource_path, "", headers)
            get_resp = conn.getresponse()
            if get_resp.status != httplib.OK:
                print 'fail, status='
                print get_resp.status
            else:
                params = json.loads(get_resp.read())
                for res in gen_data(params, "blood_sugar"):
                    post_resource_bg(urlbase, post_resource_path, headers, res)
                for res_ht in gen_data(params, "blood_pressure"):
                    post_resource_ht(urlbase, post_resource_path, headers, res_ht)
