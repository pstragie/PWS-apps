//
//  Dictionaries.swift
//  MedCabinetFree
//
//  Created by Pieter Stragier on 22/03/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import Foundation
let hyrdict0:Dictionary<String,String> = ["A":"Cardiovasculair stelsel", "B":"Bloed en stolling", "C":"Gastro-intestinaal stelsel", "D":"Ademhalingsstelsel", "E":"Hormonaal stelsel", "F":"Gynaeco-obstetrie", "G":"Urogenitaal stelsel", "H":"Pijn en koorts", "I":"Osteo-articulaire aandoeningen", "J":"Zenuwstelsel", "K":"Infecties", "L":"Immuniteit", "M":"Antitumorale middelen", "N":"Mineralen en vitaminen", "O":"Dermatologie", "P": "Oftalmologie", "Q":"Neus-Keel-Oren", "R":"Anesthesie", "S":"Diagnostica", "T":"Diverse geneesmiddelen"]
let hyrdict1:Dictionary<String,String> = ["AA":"Hypertensie", "AB":"Angina pectoris", "AC":"Hartfalen", "AD":"Diuretica", "AE":"Bèta-blokkers", "AF":"Calciumantagonisten", "AG":"Middelen inwerkend op het renine-angiotensinesysteem", "AH":"Antiaritmica", "AI":"Hypotensie", "AJ":"Arteriële vaatstoornissen", "AK":"Veno- en capillarotropica", "AL":"Hypolipemiërende middelen", "AM":"Middelen bij pulmonale hypertensie", "AN":"Alprostadil", "AO":"Middelen i.v.m. het sluiten van de ductus arteriosus", "AP":"Associaties voor cardiovasculaire preventie", "BA":"Antitrombotica", "BB":"Antihemorragica", "BC":"Middelen i.v.m. de bloedvorming", "CA":"Maag- en duodenumpathologie", "CB":"Spasmolytica", "CC":"Lever-, galblaas- en pancreaspathologie", "CD":"Anti-emetica", "CE":"Laxativa", "CF":"Antidiarreïca", "CG":"Inflammatoir darmlijden", "CH":"Anale pathologie", "DA":"Astma en COPD", "DB":"Antitussiva, mucolytica en expectorantia", "DC":"Diverse geneesmiddelen bij respiratoire aandoeningen", "EA":"Diabetes", "EB":"Schildklierpathologie", "EC":"Geslachtshormonen", "ED":"Corticosteroïden", "EE":"Hypofysaire en hypothalame hormonen", "EF":"Diverse middelen i.v.m. het hormonale stelsel", "FA":"Middelen bij vulvovaginale aandoeningen", "FB":"Anticonceptie", "FC":"Menopauze en hormonale substitutie", "FD":"Middelen i.v.m. de uterusmotiliteit", "FE":"Middelen in het kader van geassisteerde vruchtbaarheid", "FF":"Progestagenen", "FG":"Antiprogestagenen", "FH":"Lactatieremming en hyperprolactinemie", "FI":"Diverse middelen gebruikt in de gynaeco-obstetrie", "GA":"Blaasfunctiestoornissen", "GB":"Benigne prostaathypertrofie", "GC":"Impotentie", "GD": "Diverse middelen bij uro-genitale problemen", "HA":"Medicamenteuze koorts- en pijnbestrijding", "HB":"Analgetica - Antipyretica", "HC":"Opioïden", "HD":"Opioïdantagonisten", "IA":"Niet-steroïdale anti-inflammatoire middelen", "IB":"Chronische artritis", "IC":"Jicht", "ID":"Artrose", "IE":"Osteoporose en ziekte van Paget", "IF":"Diverse middelen bij osteo-articulaire aandoeningen", "JA":"Hypnotica, sedativa, anxiolytica", "JB":"Antipsychotica", "JC":"Antidepressiva", "JD":"Middelen bij ADHD en narcolepsie", "JE":"Middelen i.v.m. afhankelijkheid", "JF":"Antiparkinsonmiddelen", "JG":"Anti-epileptica", "JH":"Middelen bij spasticiteit", "JI":"Antimigrainemiddelen", "JJ":"Cholinesterase-inhibitoren", "JK":"Anti-Alzheimermiddelen", "JL":"Middelen bij de ziekte van Huntington", "JM":"Middelen bij amyotrofe laterale sclerose (ALS)", "JN":"Middelen bij multiple sclerose (MS)", "KA":"Antibacteriële middelen", "KB":"Antimycotica", "KC":"Antiparasitaire middelen", "KD":"Antivirale middelen", "LA":"Vaccins", "LB":"Immunoglobulinen", "LC":"Immunomodulatoren", "LD":"Allergie", "MA":"Alkylerende middelen", "MB":"Antimetabolieten", "MC":"Antitumorale antibiotica", "MD":"Topo-isomerase-inhibitoren", "ME":"Microtubulaire inhibitoren", "MF":"Monoklonale antilichamen en cytokines", "MG":"Proteïnekinase-inhibitoren", "MH":"Diverse antitumorale middelen", "MI":"Hormonale middelen in de oncologie", "MJ":"Middelen bij ongewenste effecten van antitumorale middelen", "NA":"Mineralen", "NB":"Vitaminen", "OA":"Anti-infectieuze middelen", "OB":"Corticosteroïden", "OC":"Middelen tegen jeuk", "OD":"Middelen bij traumata en veneuze aandoeningen", "OE":"Acne", "OF":"Rosacea", "OG":"Psoriasis", "OH":"Keratolytica", "OI":"Enzymen", "OJ":"Beschermende middelen", "OK":"Immunomodulatoren", "OL":"Diverse dermatologische middelen", "OM":"Actieve verbandmiddelen", "PA":"Anti-infectieuze middelen", "PB":"Anti-allergische en anti-inflammatoire middelen", "PC":"Decongestionerende middelen", "PD":"Mydriatica - Cycloplegica", "PE":"Antiglaucoommiddelen", "PF":"Lokale anesthetica", "PG":"Kunsttranen", "PH":"Diagnostica in de oftalmologie", "PI":"Middelen bij oogchirurgie", "PJ":"Middelen bij maculadegeneratie", "PK":"Middelen bij vitreomaculaire tractie", "QA":"Middelen voor gebruik in het oor", "QB":"Ziekte van Ménière", "QC":"Rhinitis en sinusitis", "QD":"Orofaryngeale aandoeningen", "RA":"Algemene anesthesie", "RB":"Lokale anesthesie", "SA":"Radiodiagnostica", "SB":"Diagnostica voor magnetische resonantie", "SC":"Tuberculine", "SD":"Diverse diagnostica", "TA":"Antidota en chelatoren", "TB":"Obesitas", "TC":"Aangeboren metabole aandoeningen", "TD":"Homeopathische middelen"]
class Dictionaries {
    func hierarchy(hyr:String) -> String {
        var hyrstring:String = ""
        let firstCharacter = hyr[hyr.index(hyr.startIndex, offsetBy: 0)]
        let start = hyr.index(hyr.startIndex, offsetBy: 0)
        let end = hyr.index(hyr.startIndex, offsetBy: 1)
        let range = start...end
        let firstTwoCharacters = hyr[range]
        
        if hyr.characters.count == 1 {
            hyrstring = (hyrdict0[String(firstCharacter)])!
        } else {
            hyrstring = (hyrdict0[String(firstCharacter)])! + " > " + (hyrdict1[String(firstTwoCharacters)])!
        }
        return hyrstring
    }
    
    func wada(wada:String) -> String {
        var wadastring:String = ""
        let wadadict: Dictionary<String,String> = ["A":"Anabolica, ten allen tijde verboden", "B":"Beta-blokkers, verboden bij bepaalde concentratiesporten binnen wedstrijdverband en ten alle tijde verboden bij (boog)schieten.", "B2":"Alle beta2-mimetica zijn verboden, behalve salbutamol, salmeterol en formoterol die via inhalatie en in overeenkomstig met het therapeutisch regime, worden gebruikt.", "C":"Corticosteroïden, verboden binnen wedstrijdverband behalve bij nasaal of dermatologisch gebruik of via inhalatie.", "c": "Opgelet. Corticosteroïden (nasaal, dermatologisch, inhalatie). Geen TTN (toestemming tot therapeutische noodzaak) vereist maar gebruik ervan te melden aan de controlearts.", "D":"Diuretica, ten allen tijde verboden", "d":"Opgelet. Bevat codeïne of ethylmorfine. Geen formulier toestemming tot therapeutische noodzaak vereist, maar gebruik ervan te melden aan de controlearts.", "DB":"Bevat diuretica, ten allen tijde verboden.", "Hman":"Ten allen tijde verboden voor mannelijke atleten.", "H":"Ten allen tijde verboden.", "M":"Maskerende middelen, ten allen tijde verboden.", "N":"Narcotica, verboden binnen wedstrijdverband.", "O":"Anti-oestrogene middelen, ten allen tijde verboden.", "AO":"Anti-oestrogene middelen, ten allen tijde verboden.", "P":"Opgelet! Kan mogelijk aanleiding geven tot een afwijkend analyseresultaat voor cathine. Geen 'toestemming tot therapeutische noodzaak' vereist, maar gebruik ervan te melden aan de controlearts.", "S":"Stimulantia, verboden binnen wedstrijdverband.", "s":"Opgelet! Bevat stimulantia en kan mogelijk aanleiding geven tot een positieve dopingtest. Geen 'toestemming tot therapeutische noodzaak' vereist, maar gebruik ervan te melden aan de controlearts.", "_":"Niet op de dopinglijst."]
        
        wadastring = wadadict[wada]!
        return wadastring
    }
    
    func ssecr(ssecr:String) -> String {
        let ssecrLijst = ssecr.components(separatedBy: " ")
        var ssecrstringLijst: Array<String> = []
        var ssecrstring:String = ""
        let ssecrdict: Dictionary<String,String> = ["a":"categorie a", "b":"categorie b", "c":"categorie c", "cx":"categorie cx", "cs":"categorie cs", "b2":"b2: a priori controle", "c2":"c2: a priori controle", "a4":"a4: a posteriori controle", "b4":"b4: a posteriori controle", "c4":"c4: a posteriori controle", "s4":"s4: a posteriori controle", "h": "h: enkel terugbetaling in hospitaalgebruik", "J":"J: speciale toelage door RIZIV voor vrouwen < 21j.", "aJ":"aJ: gratis voor vrouwen < 21j.", "Chr":"Chr: speciale toelage door RIZIV voor chronische pijn.", "_":"geen", "":"geen"]
        for part in ssecrLijst {
            ssecrstringLijst.append(ssecrdict[part]!)
        }
        ssecrstring = ssecrstringLijst.joined(separator: ", ")
        
        return ssecrstring
    }
    
    func level0Picker() -> Dictionary<String,String> {
        return hyrdict0
    }
    
    func level1Picker() -> Dictionary<String,String> {
        return hyrdict1
    }
}
