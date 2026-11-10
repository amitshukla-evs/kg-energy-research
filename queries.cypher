// Curated from corpus. No inferred nationality or missing dates.
// sources contains Document.id values. Document.filename identifies each source file.
// Current affiliations are corpus-described affiliations, not publication-time assertions.
// Statements end with semicolons. Do not put semicolons inside strings or comments.
// WARNING: resets all nodes in the selected database. CLI executes data statements atomically.
CREATE CONSTRAINT entity_id IF NOT EXISTS FOR (n:Entity) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT document_id IF NOT EXISTS FOR (n:Document) REQUIRE n.id IS UNIQUE;
MATCH (n) DETACH DELETE n;

UNWIND [
 '01_halvorsen_institute_of_technology.txt', '02_rhine_valley_university.txt',
 '03_southern_peninsula_institute_of_science.txt', '04_maple_ridge_university.txt',
 '05_lumen_storage_systems.txt', '06_fjordgrid_as.txt', '07_deccan_power_corporation.txt',
 '08_pacific_cell_technologies.txt', '09_european_clean_energy_council.txt',
 '10_national_science_endowment_of_india.txt', '11_canadian_innovation_fund.txt',
 '12_project_alpine.txt', '13_project_monsoon.txt', '14_project_cascade.txt',
 '15_project_reclaim.txt', '16_person_ingrid_solberg.txt', '17_person_markus_weber.txt',
 '18_person_priya_raghunathan.txt', '19_person_daniel_okafor.txt', '20_person_elena_voss.txt',
 '21_person_tomas_berg.txt', '22_paper_sodium_ion_cell_degradation.txt',
 '23_paper_cathode_stability.txt', '24_paper_thermal_management.txt',
 '25_paper_probabilistic_load_forecasting.txt', '26_paper_hydrometallurgical_recovery.txt',
 '27_paper_forecast_aware_dispatch.txt', '28_vestfjord_pilot_site.txt',
 '29_tiruvallur_test_bed.txt', '30_fraser_valley_demonstration_site.txt',
 '31_nordic_storage_symposium_2023.txt', '32_patent_lss_pat_2020_114.txt',
 '33_technology_sodium_ion_battery.txt', '34_technology_thermal_management.txt',
 '35_technology_load_forecasting.txt'
] AS filename
CREATE (:Document {id: toInteger(left(filename, 2)), filename: filename});

UNWIND [
 {id:'hit', name:'Halvorsen Institute of Technology', aliases:['HIT'], country:'Norway', kind:'university', sources:[1]},
 {id:'rvu', name:'Rhine Valley University', aliases:['RVU'], country:'Germany', kind:'university', sources:[2]},
 {id:'spis', name:'Southern Peninsula Institute of Science', aliases:['SPIS'], country:'India', kind:'institute', sources:[3]},
 {id:'maple', name:'Maple Ridge University', country:'Canada', kind:'university', sources:[4]},
 {id:'lumen', name:'Lumen Storage Systems', country:'Germany', kind:'company', sources:[5]},
 {id:'fjordgrid', name:'Fjordgrid AS', country:'Norway', kind:'utility', sources:[6,28]},
 {id:'deccan', name:'Deccan Power Corporation', country:'India', kind:'utility', sources:[7]},
 {id:'pacific', name:'Pacific Cell Technologies', country:'Canada', kind:'company', sources:[8,4]},
 {id:'ecec', name:'European Clean Energy Council', aliases:['ECEC'], kind:'funding_agency', sources:[9]},
 {id:'nsei', name:'National Science Endowment of India', aliases:['NSEI'], kind:'funding_agency', sources:[10]},
 {id:'cif', name:'Canadian Innovation Fund', aliases:['CIF'], kind:'funding_agency', sources:[11]}
] AS row
CREATE (n:Entity:Organization) SET n = row;

UNWIND [
 {id:'ingrid', name:'Ingrid Solberg', doctoral_status:'completed', sources:[16]},
 {id:'markus', name:'Markus Weber', sources:[17]},
 {id:'priya', name:'Priya Raghunathan', sources:[18]},
 {id:'daniel', name:'Daniel Okafor', sources:[19]},
 {id:'elena', name:'Elena Voss', sources:[20]},
 {id:'tomas', name:'Tomas Berg', doctoral_status:'completed', sources:[21]},
 {id:'sofia', name:'Sofia Lindqvist', doctoral_status:'ongoing', sources:[16,27]},
 {id:'katarina', name:'Katarina Novak', sources:[2,23]},
 {id:'arjun', name:'Arjun Menon', doctoral_status:'ongoing', sources:[3,13]},
 {id:'li', name:'Li Wei', sources:[4,25]},
 {id:'hannah', name:'Hannah Brooks', doctoral_status:'completed', sources:[4,8]}
] AS row
CREATE (n:Entity:Researcher) SET n = row;

UNWIND [
 {id:'alpine', name:'ALPINE', start:2021, end:2025, sources:[12]},
 {id:'monsoon', name:'MONSOON', start:2022, end:2027, sources:[13]},
 {id:'cascade', name:'CASCADE', start:2022, end:2025, sources:[14]},
 {id:'reclaim', name:'RECLAIM', start:2022, end:2027, sources:[15]}
] AS row
CREATE (n:Entity:Project) SET n = row;

UNWIND [
 {id:'degradation', title:'Sodium-Ion Cell Degradation Under Variable Grid Loads', year:2023, sources:[22]},
 {id:'cathode', title:'Sodium-Ion Cathode Stability in Solid-State Electrolytes', year:2022, sources:[23]},
 {id:'thermal', title:'Thermal Management Strategies for Stationary Batteries in Hot Climates', year:2024, sources:[24]},
 {id:'forecasting', title:'Probabilistic Load Forecasting with Gradient-Boosted Models', year:2023, sources:[25]},
 {id:'recovery', title:'Hydrometallurgical Recovery of Sodium-Ion Cathode Materials', year:2024, sources:[26]},
 {id:'dispatch', title:'Forecast-Aware Dispatch of Grid Batteries', year:2025, sources:[27]}
] AS row
CREATE (n:Entity:Publication) SET n = row;

UNWIND [
 {id:'vestfjord', name:'Vestfjord Pilot Site', country:'Norway', commissioned:2024, sources:[28]},
 {id:'tiruvallur', name:'Tiruvallur Test Bed', country:'India', commissioned:2025, sources:[29]},
 {id:'fraser', name:'Fraser Valley Demonstration Site', country:'Canada', commissioned:2024, sources:[30]}
] AS row
CREATE (n:Entity:Site) SET n = row;

CREATE (:Entity:Patent {id:'LSS-PAT-2020-114', title:'Layered Sodium-Ion Cell with Composite Electrolyte Interface', filed:2020, granted:2022, sources:[32]});

UNWIND [
 {id:'sodium_ion', name:'Sodium-ion batteries', sources:[33]},
 {id:'solid_electrolytes', name:'Solid-state electrolytes', sources:[23]},
 {id:'thermal_management', name:'Thermal management', sources:[34]},
 {id:'load_forecasting', name:'Load forecasting', sources:[35]},
 {id:'battery_degradation', name:'Battery degradation modelling', sources:[22,27,34]},
 {id:'battery_recycling', name:'Battery recycling', sources:[26,33]}
] AS row
CREATE (n:Entity:Technology) SET n = row;

UNWIND [
 {person:'ingrid', org:'hit', props:{kind:'employment', current:true, start:2008, sources:[16]}},
 {person:'ingrid', org:'rvu', props:{kind:'doctoral_study', current:false, completed:2005, sources:[16]}},
 {person:'markus', org:'rvu', props:{kind:'employment', current:true, sources:[17]}},
 {person:'priya', org:'spis', props:{kind:'employment', current:true, sources:[18]}},
 {person:'priya', org:'maple', props:{kind:'visiting_scholar', current:false, start:2019, end:2019, sources:[18]}},
 {person:'daniel', org:'maple', props:{kind:'employment', current:true, sources:[19]}},
 {person:'elena', org:'lumen', props:{kind:'employment', current:true, start:2019, sources:[20]}},
 {person:'elena', org:'rvu', props:{kind:'postdoc', current:false, start:2015, end:2019, sources:[20]}},
 {person:'tomas', org:'fjordgrid', props:{kind:'employment', current:true, start:2016, sources:[6,21]}},
 {person:'tomas', org:'hit', props:{kind:'doctoral_study', current:false, completed:2016, sources:[21]}},
 {person:'sofia', org:'hit', props:{kind:'doctoral_study', current:true, sources:[16,27]}},
 {person:'katarina', org:'rvu', props:{kind:'employment', current:true, sources:[2]}},
 {person:'arjun', org:'spis', props:{kind:'doctoral_study', current:true, sources:[3]}},
 {person:'li', org:'maple', props:{kind:'employment', current:true, sources:[4]}},
 {person:'hannah', org:'pacific', props:{kind:'employment', current:true, sources:[8]}},
 {person:'hannah', org:'maple', props:{kind:'doctoral_study', current:false, completed:2018, sources:[4,8]}}
] AS row
MATCH (p:Researcher {id:row.person}), (o:Organization {id:row.org})
CREATE (p)-[r:AFFILIATED_WITH]->(o) SET r = row.props;

// Only explicitly described transitions. A sabbatical is not a permanent job move.
UNWIND [
 {person:'ingrid', target:'hit', props:{from_id:'rvu', year:2008, kind:'joined after doctorate', sources:[16]}},
 {person:'elena', target:'lumen', props:{from_id:'rvu', year:2019, kind:'postdoc to employment', sources:[20]}},
 {person:'tomas', target:'fjordgrid', props:{from_id:'hit', year:2016, kind:'doctorate to employment', sources:[6,21]}},
 {person:'hannah', target:'pacific', props:{from_id:'maple', kind:'after doctorate completed in 2018', sources:[4,8]}},
 {person:'priya', target:'maple', props:{from_id:'spis', year:2019, kind:'temporary sabbatical visit', sources:[18]}}
] AS row
MATCH (p:Researcher {id:row.person}), (o:Organization {id:row.target})
CREATE (p)-[r:MOVED_TO]->(o) SET r = row.props;

UNWIND [
 {student:'ingrid', supervisor:'markus', sources:[16,17]},
 {student:'tomas', supervisor:'ingrid', sources:[16,21]},
 {student:'sofia', supervisor:'ingrid', sources:[16]},
 {student:'arjun', supervisor:'priya', sources:[18]},
 {student:'hannah', supervisor:'daniel', sources:[8,19]}
] AS row
MATCH (a:Researcher {id:row.student}), (b:Researcher {id:row.supervisor})
CREATE (a)-[:SUPERVISED_BY {sources:row.sources}]->(b);

MATCH (a:Researcher {id:'elena'}), (b:Researcher {id:'markus'})
CREATE (a)-[:POSTDOC_UNDER {sources:[20]}]->(b);

UNWIND [
 {org:'hit', project:'alpine', role:'coordinator', sources:[12]},
 {org:'rvu', project:'alpine', role:'materials: solid-state electrolytes', sources:[12]},
 {org:'lumen', project:'alpine', role:'cell manufacturing', sources:[12]},
 {org:'fjordgrid', project:'alpine', role:'pilot operation', sources:[12]},
 {org:'spis', project:'monsoon', role:'coordinator', sources:[13]},
 {org:'deccan', project:'monsoon', role:'grid connection and operational data', sources:[7,13]},
 {org:'maple', project:'monsoon', role:'modelling', sources:[13]},
 {org:'maple', project:'cascade', role:'coordinator', sources:[14]},
 {org:'pacific', project:'cascade', role:'commercial software integration', sources:[14]},
 {org:'hit', project:'cascade', role:'battery degradation models', sources:[14]},
 {org:'rvu', project:'reclaim', role:'coordinator', sources:[15]},
 {org:'lumen', project:'reclaim', role:'production scrap and used cells', sources:[15]}
] AS row
MATCH (o:Organization {id:row.org}), (p:Project {id:row.project})
CREATE (o)-[:PARTICIPATES_IN {role:row.role, sources:row.sources}]->(p);

UNWIND [
 {agency:'ecec', project:'alpine', amount:4200000, currency:'EUR', sources:[9,12]},
 {agency:'ecec', project:'reclaim', amount:3100000, currency:'EUR', sources:[9,15]},
 {agency:'nsei', project:'monsoon', amount:380000000, currency:'INR', sources:[10]},
 {agency:'cif', project:'cascade', amount:2800000, currency:'CAD', sources:[11,14]}
] AS row
MATCH (a:Organization {id:row.agency}), (p:Project {id:row.project})
CREATE (a)-[:FUNDS {amount:row.amount, currency:row.currency, sources:row.sources}]->(p);

UNWIND [
 {paper:'degradation', authors:['ingrid','sofia','tomas'], project:'alpine', sources:[22]},
 {paper:'cathode', authors:['katarina','ingrid','elena'], project:'alpine', sources:[23]},
 {paper:'thermal', authors:['priya','arjun','daniel'], project:'monsoon', sources:[24]},
 {paper:'forecasting', authors:['daniel','li','hannah'], project:'cascade', sources:[25]},
 {paper:'recovery', authors:['markus','katarina'], project:'reclaim', sources:[26]},
 {paper:'dispatch', authors:['hannah','sofia','daniel'], project:'cascade', sources:[27]}
] AS row
MATCH (paper:Publication {id:row.paper}), (project:Project {id:row.project})
CREATE (paper)-[:OUTPUT_OF {sources:row.sources}]->(project)
WITH row, paper
UNWIND range(0, size(row.authors)-1) AS position
MATCH (person:Researcher {id:row.authors[position]})
CREATE (person)-[:AUTHORED {position:position+1, sources:row.sources}]->(paper);

UNWIND [
 {from:'degradation', to:'cathode', sources:[22]},
 {from:'thermal', to:'degradation', sources:[24]},
 {from:'recovery', to:'cathode', sources:[26]},
 {from:'dispatch', to:'forecasting', sources:[27]},
 {from:'dispatch', to:'degradation', sources:[27]}
] AS row
MATCH (a:Publication {id:row.from}), (b:Publication {id:row.to})
CREATE (a)-[:CITES {sources:row.sources}]->(b);

// Topic tags describe the papers' stated subject matter, not inferred research interests.
UNWIND [
 {paper:'degradation', topics:['sodium_ion','battery_degradation'], sources:[22]},
 {paper:'cathode', topics:['sodium_ion','solid_electrolytes'], sources:[23]},
 {paper:'thermal', topics:['sodium_ion','thermal_management','battery_degradation'], sources:[24]},
 {paper:'forecasting', topics:['load_forecasting'], sources:[25]},
 {paper:'recovery', topics:['sodium_ion','battery_recycling'], sources:[26]},
 {paper:'dispatch', topics:['load_forecasting','battery_degradation'], sources:[27]}
] AS row
MATCH (p:Publication {id:row.paper})
UNWIND row.topics AS topic
MATCH (t:Technology {id:topic})
CREATE (p)-[:ABOUT {sources:row.sources}]->(t);

UNWIND [
 {site:'vestfjord', project:'alpine', operators:['fjordgrid','hit'], sources:[28]},
 {site:'tiruvallur', project:'monsoon', operators:['spis','deccan'], sources:[29]},
 {site:'fraser', project:'cascade', operators:['maple','pacific'], sources:[30]}
] AS row
MATCH (s:Site {id:row.site}), (p:Project {id:row.project})
CREATE (s)-[:ESTABLISHED_UNDER {sources:row.sources}]->(p)
WITH row, s
UNWIND row.operators AS operator
MATCH (o:Organization {id:operator})
CREATE (o)-[:OPERATES {sources:row.sources}]->(s);

MATCH (o:Organization {id:'lumen'}), (p:Patent {id:'LSS-PAT-2020-114'})
CREATE (o)-[:HOLDS {sources:[32]}]->(p);

UNWIND ['elena','katarina'] AS inventor
MATCH (r:Researcher {id:inventor}), (p:Patent {id:'LSS-PAT-2020-114'})
CREATE (r)-[:INVENTED {sources:[32]}]->(p);

UNWIND ['vestfjord','tiruvallur'] AS site
MATCH (s:Site {id:site}), (p:Patent {id:'LSS-PAT-2020-114'})
CREATE (s)-[:USES_PATENT {sources:[32]}]->(p);

MATCH (patent:Patent {id:'LSS-PAT-2020-114'}), (project:Project {id:'alpine'})
CREATE (patent)-[:LICENSED_IN {sources:[32]}]->(project);
