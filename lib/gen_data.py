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

def gen_bg(days):
    curr = datetime.now()-timedelta(days=days-1)
    prebreakfast = np.random.normal(9.458, 3.923, days)
    prebreakfast2 = np.random.normal(7.953, 3.387, days)
    prelunch = np.random.normal(7.84, 3.53, days)
    presupp = np.random.normal(8.958, 3.687, days)
    presleep = np.random.normal(8.342, 4.02, days)
    timediff = np.random.normal(0, 20*60, days*4)
    idx = 0
    for i in range(days):
        bgtime = datetime(curr.year, curr.month, curr.day)+timedelta(hours=8, seconds=timediff[idx])
        idx += 1
        pb = prebreakfast[i]
        if i>days/2:
            pb = prebreakfast2[i]
        res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Pre_breakfast_blood_glucose_measurement, pb)
        yield res

        bgtime = datetime(curr.year, curr.month, curr.day)+timedelta(hours=12, seconds=timediff[idx])
        idx += 1
        res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Pre_lunch_blood_glucose_measurement, prelunch[i])
        yield res
        
        bgtime = datetime(curr.year, curr.month, curr.day)+timedelta(hours=18, seconds=timediff[idx])
        idx += 1
        res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Pre_supper_blood_glucose_measurement, presupp[i])
        yield res

        bgtime = datetime(curr.year, curr.month, curr.day)+timedelta(hours=21, seconds=timediff[idx])
        idx += 1
        res = Meas(bgtime.strftime("%Y-%m-%d %H:%M:%S"), Unspecified_blood_glucose_measurement1, presleep[i])
        yield res
        
        curr = curr+timedelta(days=1)
        
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
        prf_resp = conn.getresponse()
        if prf_resp.status == httplib.OK:
            profile = json.loads(prf_resp.read())
            #print "user_id="+str(profile['id'])+' token='+token
            resource_path = "/api/v1/users/"+str(profile['id'])+"/measurements"
            #print resource_path
            for res in gen_bg(50):
                post_resource(urlbase, resource_path, headers, res)
