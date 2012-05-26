import os
import BeautifulSoup
import string
import json

def read_file(path):
    result = False
    try:
        f = open(path, "r")
        result = ''.join(f.readlines())
        f.close()
    except IOError:
        pass
    return result

def is_drug(html):
    soup = BeautifulSoup.BeautifulSoup(html)
    return soup.find('h3', text="Dose")

def parse_drug(html):
    drug = {}

    #get the title
    soup = BeautifulSoup.BeautifulSoup(html)
    title = soup.findAll('h1')
    drug['name'] = title[0].text

    #get the parts
    parts = soup.findAll('div', {'class': 'cAF'})
    for part in parts:
        if part.find('h2'):
            part_name = part.find('h2').text.lower()
            if part_name == 'dose':
                dose_html = part.findAll('p')
                doses = []
                for dose in dose_html:
                    doses.append(dose.text)
                drug['doses'] = doses
            else:
                drug[part_name] = part.find('p').text
    return drug

data_dir = 'data/mc/bnf/current'
pages=os.listdir(data_dir)
drugs = {}
for page in pages:
    
    # print "opening file: " +  page
    html = read_file(data_dir + '/' + page)
    if html:
        if is_drug(html):
            try:
                drug = parse_drug(html)
            except:
                pass
            drugs[drug['name']] = drug


#make into json
print json.dumps(drugs)