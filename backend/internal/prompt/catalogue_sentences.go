package prompt

// canonicalSentences renders each Listed Constraint id of the catalogue as the
// hard rule the model sees (ADR 0005). The meaning of a Listed Constraint is
// fixed here, not by the user's wording, so these sentences are part of the
// prompt and fall under Version. Kosher and halal need the most care and the
// most golden-set cases (ADR 0006).
var canonicalSentences = map[string]string{
	"diet.vegan":       "Vegan: no meat, poultry, fish, seafood, eggs, dairy, honey or any other animal-derived ingredient, including gelatine, animal rennet, lard, fish sauce and Worcestershire sauce.",
	"diet.vegetarian":  "Vegetarian: no meat, poultry, fish or seafood and nothing derived from them, including gelatine, lard, fish sauce, oyster sauce, anchovy, Worcestershire sauce, meat stock and animal rennet; eggs and dairy are allowed.",
	"diet.pescatarian": "Pescatarian: no meat or poultry and nothing derived from them, including lard, gelatine, meat stock and bacon; fish, seafood, eggs and dairy are allowed.",
	"diet.kosher":      "Kosher: no pork, rabbit, shellfish, crustaceans, molluscs, or fish without both fins and scales (no catfish, eel, shark, swordfish); meat and poultry only from kosher species, assumed kosher-slaughtered; never combine meat or poultry with any dairy in the same recipe (no butter, cheese, cream, yoghurt or milk with meat, and no dairy-based sauce on meat); no blood-based ingredients; gelatine and rennet only if described as kosher; do not pair fish with meat in the same dish.",
	"diet.halal":       "Halal: no pork or anything derived from pig, including bacon, ham, lard, pork gelatine and pork-based stocks; no alcohol in any form, including wine, beer, spirits, mirin, sake, cooking wine, alcohol-based vanilla extract and rum-soaked fruit; no blood or blood products; no meat from carnivores or birds of prey; meat and poultry are assumed halal-slaughtered.",

	"allergen.gluten":      "No gluten: no wheat, rye, barley, oats, spelt, kamut, semolina, durum, bulgur, couscous, freekeh, farro, seitan, wheat flour, bread, breadcrumbs, regular pasta, noodles made from wheat, malt, beer or regular soy sauce; only ingredients that are naturally gluten-free or labelled gluten-free (such as tamari), and say so in preparation where it matters.",
	"allergen.crustaceans": "No crustaceans: no shrimp, prawns, crab, lobster, crayfish, langoustine, or pastes, powders and stocks made from them.",
	"allergen.eggs":        "No eggs or egg-derived ingredients: no whole eggs, egg whites, egg yolks, mayonnaise, aioli, meringue, custard, egg noodles, fresh egg pasta, egg wash or albumen.",
	"allergen.fish":        "No fish or fish-derived ingredients: no fish of any kind, fish sauce, fish stock, dashi made with bonito, anchovy or anchovy paste, Worcestershire sauce, Caesar dressing, or fish roe.",
	"allergen.peanuts":     "No peanuts or peanut-derived ingredients: no peanuts, peanut butter, peanut oil, groundnut oil, satay sauce, or nut mixes that contain peanuts.",
	"allergen.soy":         "No soy or soy-derived ingredients: no soybeans, edamame, tofu, tempeh, soy milk, soy sauce, tamari, shoyu, miso, natto, soy protein, textured vegetable protein, soy lecithin or soybean oil.",
	"allergen.milk":        "No milk or dairy from any animal: no milk, butter, ghee, cheese, cream, crème fraîche, yoghurt, kefir, whey, casein, milk powder, condensed milk, ice cream or paneer; plant-based alternatives are allowed.",
	"allergen.tree-nuts":   "No tree nuts or tree-nut-derived ingredients: no almonds, walnuts, cashews, pistachios, pecans, hazelnuts, Brazil nuts, macadamias, pine nuts, chestnuts, nut butters, nut oils, nut flours, marzipan, praline, pesto made with nuts, or nut milks.",
	"allergen.celery":      "No celery: no celery stalks, leaves or seeds, celeriac, celery salt, or stocks, bouillon and spice mixes that contain celery.",
	"allergen.mustard":     "No mustard: no mustard seeds, mustard powder, prepared mustard, mustard oil, mustard greens, or dressings, curry pastes and spice mixes that contain mustard.",
	"allergen.sesame":      "No sesame: no sesame seeds, sesame oil, tahini, halva, hummus made with tahini, gomashio, or za'atar and spice mixes that contain sesame.",
	"allergen.sulphites":   "No sulphites: no wine, cider, wine vinegar, balsamic vinegar, dried fruit, bottled lemon or lime juice, grape juice, or processed and pickled foods likely to carry sulphite preservatives.",
	"allergen.lupin":       "No lupin: no lupin flour, lupin beans, lupin protein, or baked goods and pasta that contain lupin.",
	"allergen.molluscs":    "No molluscs: no mussels, clams, oysters, scallops, cockles, squid, calamari, octopus, cuttlefish, snails, abalone, or oyster sauce.",
}
