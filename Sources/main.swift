import Foundation
struct Input: Decodable { let pantry:[PantryItem]; let recipes:[Recipe] }
do {
 let data=FileHandle.standardInput.readDataToEndOfFile();let input=try JSONDecoder().decode(Input.self,from:data)
 guard input.pantry.allSatisfy({$0.quantity.isFinite && $0.quantity >= 0}) else {throw NSError(domain:"input",code:1)}
 let ranking=SuggestionEngine().rankRecipes(pantry:input.pantry,recipes:input.recipes,preferredLimit:input.recipes.count,priorSelections:[])
 let plan=WeekPlanner().makeWorkweekPlan(pantry:input.pantry,recipes:input.recipes)
 let result:[String:Any]=["suggestions":ranking.map{["name":$0.recipe.name,"coverage":$0.coverage,"score":$0.score] as [String:Any]},"planned_days":plan.count]
 let encoded=try JSONSerialization.data(withJSONObject:result,options:[.sortedKeys]);print(String(data:encoded,encoding:.utf8)!)
} catch {fputs("Invalid input: \(error)\n",stderr);exit(2)}
