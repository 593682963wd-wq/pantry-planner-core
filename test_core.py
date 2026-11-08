import unittest,tempfile,json
from pathlib import Path
from core import run

class Tests(unittest.TestCase):
 def test_empty_plan(self):self.assertEqual(run({'pantry':[],'recipes':[]})['planned_days'],5)
 def test_bad_input(self):
  with self.assertRaises(ValueError):run({})

if __name__=="__main__":unittest.main()

class PlannerTests(unittest.TestCase):
 def test_inventory_ranking(self):
  r=run(json.loads(Path('example.json').read_text()));self.assertEqual(r['suggestions'][0]['coverage'],1);self.assertEqual(r['planned_days'],5)
