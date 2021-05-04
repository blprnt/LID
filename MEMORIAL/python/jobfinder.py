import sys
from find_job_titles import FinderAcora
finder=FinderAcora()

# simple JSON echo script
for line in sys.stdin:
  print(finder.findall(line[:-1]))
