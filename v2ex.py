#!/usr/bin/env python
#coding:utf-8

import requests
import re
import sys

reload(sys)
sys.setdefaultencoding('utf-8')

username = sys.argv[1]
password = sys.argv[2]
index_url = "http://www.v2ex.com"
login_url = "http://www.v2ex.com/signin"
daily_url = "http://www.v2ex.com/mission/daily"
headers = {
    "User-Agent": "UA",
    "Host": "v2ex.com",
    "Origin": "http://v2ex.com",
    "Referer": "http://www.v2ex.com/signin"
}

s = requests.Session()


def extract(s, start, end, rm_prefix=True):
    s_ = None
    p = "{0}.*?{1}".format(start, end)
    s = re.findall(p, s)
    if s:
        s_ = s[0]
        if rm_prefix:
            s_ = s_.replace(start, '').replace(end, '')
    return s_


def extract_all(s, start, end):
    s_list = []
    p = "{0}.*?{1}".format(start, end)
    s = re.findall(p, s)
    if s:
        for o in s:
            s_list.append(o.replace(start, '').replace(end, ''))

    return s_list


def trim(s):
    return s.strip()


def get_once_value():
    once_value = ''
    login_page = s.get(login_url, headers=headers, verify=False).text

    once_value = extract(login_page, '<input type="hidden" value="',
                         '" name="once" />')
    name_key   = extract(login_page, '<input type="text" class="sl" name="',
                         '" value="" autofocus="autofocus" autocorrect="off" spellcheck="false"')
    pass_key   = extract(login_page, '<input type="password" class="sl" name="',
                         '" value="" autocorrect="off" spellcheck="false" autocapitalize="off"')
    return once_value, name_key, pass_key


def get_post_data():
    once_value, name_key, pass_key = get_once_value()
    post_data = {
        "next": "/",
        name_key: username,
        pass_key: password,
        "once": once_value,
        "next": "/"
    }

    return post_data


def login():
    log("正在登录...")
    post_data = get_post_data()
    r = s.post(login_url, data=post_data, headers=headers, verify=False)


def show_balance():
    balanch = 0
    r = s.get(index_url, headers=headers, verify=False)
    
    html = r.text

    balance_area = extract(html,
                           '<a href="/balance" class="balance_area" style="">',
                           '</a>', False)
    if balance_area:
        log("获取账户余额...")
        s_list = map(trim, filter(None, extract_all(balance_area, '>', '<')))
        log("账户余额为{0}".format(''.join(s_list)))

        return True
    else:
        log("登录失败!!!")

        return False

    return balanch


def exe():
    log("开始领金币...")
    r = s.get(daily_url, headers=headers, verify=False)
    html = r.text
    href = extract(html, "/mission/daily/redeem", "';")
    if href:
        mission_url = "{0}/mission/daily/redeem{1}".format(index_url, href)
        r = s.get(mission_url, headers=headers, verify=False)
        log("执行任务结束，再次查看用户余额...")
    else:
        log("执行任务失败!!! 是不是已经认领了？")


def log(msg):
    print msg
    #with open("log.txt", "a") as f:
    #    f.write(msg)
    #    f.write('\n')

if __name__ == "__main__":
    login()
    if show_balance():
        exe()
        show_balance()
