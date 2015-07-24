import json
import urllib, httplib
from collections import namedtuple

def gen_bg():
    pass

if __name__ == "__main__":
    params = None
    with open('../SmartUtils/smartdiab.json', 'r') as f:
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
            print "user_id="+profile['id']

            gen_bg()
            
    gen_bg(1)