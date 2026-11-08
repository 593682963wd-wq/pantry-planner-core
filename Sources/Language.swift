import Foundation
public enum AppContentLanguage { case chinese,english
 public func text(_ chinese:String,_ english:String)->String { self == .chinese ? chinese : english }
}
extension RecipeIngredient { public func displayName(in language:AppContentLanguage)->String { name } }
