"""作者：Wangyuan；日期：2026-11-08。职责：通过合成输入复验已确认缺陷。"""
import unittest,tempfile,subprocess
from pathlib import Path
class ReleaseTests(unittest.TestCase):
 def test_inventory_batches_units_and_shared_week_stock(self) -> None:
  code='''import Foundation
let pantry=[PantryItem(name:"Rice",category:.pantry,quantity:1,unit:.cup,expiresInDays:5),PantryItem(name:" rice ",category:.pantry,quantity:1,unit:.cup,expiresInDays:2)]
func recipe(_ unit:PantryUnit)->Recipe {Recipe(name:"meal",subtitle:"",minutes:10,serves:1,accentHex:"000000",requiredIngredients:[RecipeIngredient(name:"rice",amount:2,unit:unit,aisle:.dryGoods)],steps:[],leftoverNote:"")}
let r=recipe(.cup)
let ranked=SuggestionEngine().rankRecipes(pantry:pantry,recipes:[r,recipe(.pound)])
assert(ranked.first!.coverage==1)
assert(ranked.last!.coverage==0)
let gaps=GroceryPlanner().buildList(plan:[PlannedDinner(slot:.monday,recipeID:r.id),PlannedDinner(slot:.tuesday,recipeID:r.id)],pantry:pantry,recipes:[r])
assert(gaps.count==1 && gaps[0].amount==2)
let other=recipe(.pound)
let unitGaps=GroceryPlanner().buildList(plan:[PlannedDinner(slot:.monday,recipeID:r.id),PlannedDinner(slot:.tuesday,recipeID:other.id)],pantry:[],recipes:[r,other])
assert(unitGaps.count==2 && Set(unitGaps.map(\.id)).count==2)
print("inventory cases passed")
'''
  with tempfile.TemporaryDirectory() as d:
   main=Path(d)/'main.swift';main.write_text(code);binary=Path(d)/'check';sources=[str(p) for p in sorted(Path('Sources').glob('*.swift')) if p.name!='main.swift']
   r=subprocess.run(['swiftc',*sources,str(main),'-o',str(binary)],capture_output=True,text=True,timeout=120);self.assertEqual(r.returncode,0,r.stderr)
   r=subprocess.run([str(binary)],capture_output=True,text=True,timeout=15);self.assertEqual(r.returncode,0,r.stderr)
