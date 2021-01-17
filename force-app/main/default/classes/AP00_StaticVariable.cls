public with sharing class AP00_StaticVariable {

        public static final Map<String, String> CASE_COMPONENT_NAME_BY_RECORDTYPE = new Map<String, String> {
                'CBM_Proposition_de_rachat_anticip' => 'CreateCaseGeneric',
                'CBM_Domiciliation_bancaire' => 'CreateCaseGeneric',
                'CBM_Deces' => 'CreateCaseGeneric',
                'CBM_Incapacite' => 'CreateCaseGeneric',
                'CBM_Relocation' => 'CreateCaseGeneric',
                'CBM_Reamenagement' => 'CreateCaseGeneric',
                'CBM_Reclamation' => 'CreateCaseCBMReclamation',
                'CBM_SAV' => 'CreateCaseCBMSav',
                'CBM_Sinistre_materiel' => 'CreateCaseGeneric',
                'CBM_Transfert' => 'CreateCaseCBMTransfert',
                'CBM_Transfert_Pilote_DCR3' => 'CreateCaseCBMTransfertPilote',
                'CBM_Vente_fonds_de_commerce' => 'CreateCaseGeneric',
                'CBM_Valorisation' => 'CreateCaseCBMValorisation'
        };

        public static final Map<String, Boolean> CASE_ACCESS_FROM_OPPORTUNITY_BY_RECORDTYPE = new Map<String, Boolean> {
                'CBM_Proposition_de_rachat_anticip' => false,
                'CBM_Domiciliation_bancaire' => false,
                'CBM_Deces' => false,
                'CBM_Incapacite' => false,
                'CBM_Relocation' => false,
                'CBM_Reamenagement' => false,
                'CBM_Reclamation' => true,
                'CBM_SAV' => false,
                'CBM_Sinistre_materiel' => false,
                'CBM_Transfert' => false,
                'CBM_Transfert_Pilote_DCR3' => false,
                'CBM_Vente_fonds_de_commerce' => false,
                'CBM_Valorisation' => true
        };

        public static final Map<String, String> CASE_ZONE_RECOMMANDATION_BY_RECORDTYPE = new Map<String, String> {
                'CBM_Proposition_de_rachat_anticip' =>  '• Cette demande est pour adresser au client un montant de rachat anticipé.<br />' +
                        '• Indiquer la date à laquelle le calcul doit être fait.<br />' +
                        '• Pour les rachats anticipés partiels, penser à indiquer l’immatriculation du véhicule concerné lorsque le contrat porte sur plusieurs véhicules ou une flotte.<br />' +
                        '• Dans le cas d’un pool, ou d’une contre-garantie BPI, communiquer le nom de la personne à contacter chez les partenaires.<br />',

                'CBM_Domiciliation_bancaire' => '• GED :<br />' +
                        '  (code type document SAV_domiciliation bancaire)<br />' +
                        '• Penser à insérer la dérogation de frais dans la GED le cas échéant<br />' +
                        '• Penser à mettre le nouveau RIB en GED<br />' +
                        '• Préciser dans la zone commentaire qu’ils ont été déposés en GED',

                'CBM_Deces' => '• Indiquer le nom et l\'adresse du notaire dans la zone Commentaire<br />' +
                        '• GED penser à mettre en GED l’acte de décès<br />' + 
                        '  (code type document SAV_Décès / Incapacité)<br />' +
                        '• Préciser dans la zone Commentaire qu’ils ont été déposés en GED',

                'CBM_Incapacite' => '• Attention à ne pas mettre en GED la copie d’arrêt de travail (ou autre pièce à caractère médical) : demander au client de mettre sous pli fermé le document pour envoi postal à Médecin Conseil AON France - 28 Allée de Bellevue 16918 ANGOULEME CEDEX 09.<br />' +
                        '• Indiquer si le client est en arrêt maladie et s’il souhaite une prise en charge assurance (information sur le dossier)',

                'CBM_Relocation' => '• Demande essentiellement utilisée pour les grands comptes<br />' +
                        '• Renseigner la date de demande d’accord délégation / banque et DEN<br />' +
                        '• Préciser dans la zone Commentaire si l’accord est ok ou en cours<br />' +
                        '• Renseigner la date de proposition client et d’acceptation par le client<br />' +
                        '• Dans la zone Commentaire, préciser si l’accord a été reçu et s\'il y a des garanties supplémentaires demandées (ou si les garanties d’origine sont maintenues)',

                'CBM_Reamenagement' => '• Insérer en GED les accords et tous les documents pour la mise en place du réaménagement<br />' +
                        '  (code type document : SAV_Réaménagement)<br />' +
                        '• Préciser dans la zone Commentaire qu’ils ont été déposés en GED',

                'CBM_Reclamation' => '• Dans la zone Commentaire: bien expliquer le sujet de la réclamation<br />' +
                        '• En cas de pièces jointes (ex : mail client) utiliser<br />' + 
                        '  code type document SAV_Réclamations<br />' +
                        '• Préciser dans la zone Commentaire que les documents ont été déposés en GED',

                'CBM_SAV' => '• Penser à cocher le type de SAV dans les choix proposés afin d’affiner la demande au maximum et d’en faciliter la lecture pour le gestionnaire qui l’aura en charge<br />' +
                        '• Ex : en cas de duplicata, compléter la zone Détail du duplicata (contrat, facture)<br />' +
                        '• Ex : Pour tout autre SAV, expliquer de quoi il s’agit<br />' +
                        '• Compléter la zone Commentaire du tiers concerné',

                'CBM_Sinistre_materiel' => '• Renseigner dans la zone Commentaire la date du sinistre si connnue.<br />' +
                        '• Préciser s’il s’agit d’un sinistre partiel ou total (sur le nombre de matériels)<br />' +
                        '• Indiquer, si possible, les coordonnées de l’assureur du client',

                'CBM_Transfert' =>  '•	Indiquer s’il s’agit d’un transfert total ou partiel<br />' +
                        '•	Renseigner la date de demande d’accord délégation / banque, DEN et BPI<br />' +
                        '•	Renseigner le Montant des frais<br />' +
                        '•	Renseigner la Date d’effet du transfert<br />' +
                        '•	Préciser dans la zone Commentaire si l’accord est ok ou en cours<br />' +
                        '•	La banque doit rester garante de l’opération, sinon prévoir un rachat anticipé<br />' +
                        '•	En mode schéma commissionnaire il ne peut y avoir de changement de crédit bailleur ni de pool de risque. Le crédit bailleur à l’origine du dossier reste crédit bailleur jusqu’à la fin du contrat et contre garant quand bien même le nouveau preneur n’est pas client de la banque (que le nouveau preneur soit client d’un autre réseau du groupe BPCE ou hors réseau BPCE)<br />' +
                        '•	GED :<br />' + 
                        '   (code type document transfert)<br />' +
                        '&nbsp;&nbsp;&nbsp;&nbsp;o Penser à mettre en GED les KBIS et RIB du nouveau preneur ainsi que tous les éléments essentiels au dossier<br />' +
                        '&nbsp;&nbsp;&nbsp;&nbsp;o	Préciser dans la zone Commentaire qu’ils ont été déposés en GED<br />',
                    
                'CBM_Transfert_Pilote_DCR3' =>  '•	Indiquer s’il s’agit d’un transfert total ou partiel<br />' +
                        '•	La banque doit rester garante de l’opération, sinon prévoir un rachat anticipé<br />' +
                        '•	En mode schéma commissionnaire il ne peut y avoir de changement de crédit bailleur ni de pool de risque. Le crédit bailleur à l’origine du dossier reste crédit bailleur jusqu’à la fin du contrat et contre garant quand bien même le nouveau preneur n’est pas client de la banque (que le nouveau preneur soit client d’un autre réseau du groupe BPCE ou hors réseau BPCE)<br />' +
                        '•	En cas de transfert EI vers société, caution obligatoire, à défaut risque 100% banque, ou 50/50 si accord banque et validation DCR<br />',

                'CBM_Vente_fonds_de_commerce' =>    '• GED : penser à mettre en GED le compromis de vente ou le courrier de l’avocat ou du notaire en charge de la cession<br />' +
                        '   (code type document SAV_vente de fonds de commerce)<br />' +
                        '• Préciser dans la zone Commentaire qu’ils ont été déposés en GED<br />' +
                        '• Si un transfert de contrat est prévu, joindre les accords délégation / banque, DEN et BPI',

                'CBM_Valorisation' =>       '• Une demande de valo est à faire par matériel différent pour un même financement.<br />' +
                        '• Une seule demande est à faire pour les matériels atypiques constituant un groupe de biens (ex : Boulangerie)<br />' +
                        '• Les documents utiles types devis et bon de commandes devront être mis dans la GED dans « Docs divers »'


        };
        
        public static final String VALORISATION_POPUP = '<table><tr><th>NON ROULANT</th><th>Matériel < 5 ans</th><th>Matériel > 5 ans ou démo</th></tr><tr><td>Mt financé < 75K € HT</td><td>Pas de demande de valo</td><td>Demande de valo</td></tr><tr><td>Mt financé > 75K € HT</td><td>Pas de demande de valo si durée conforme à la politique des risques</td><td>Demande de valo</td></tr></table>' +
            											'<table class="slds-m-top_medium"><tr><td>ROULANT</td></tr><tr><td><u>Demande de valo si:</u><br/>Montant financé > à 20 K€<br/>ET<br/>Montant financé > à 120% de la cote Argus</td></tr></table>' +
                                                        '<div class="slds-m-top_medium">Merci de valider que vous souhaitez toujours créer une demande de Valorisation</div>';
    
    	public static final String DOC_FUSION_ABSORPTION =  '• Kbis repreneur.<br />' +
                                                            '• Rib repreneur<br />' +
                                                            '• Pv constatant fusion absorption ou copie Journal Officiel';
    	public static final String DOC_PASSAGE_EI_VERS_SARL =  '• (Attention caution du gérant obligatoire si transformation EI en société si pas caution = risque 100% banque – à mettre en information).<br />' +
                                                               '• Kbis<br />' +
                                                               '• RIB';
        public static final String DOC_CHANGMT_CLIENT_NVX_LOCATAIRE =  '• Kbis repreneur.<br />' +
                                                                       '• Rib repreneur<br />' +
                                                                       '• Accord BP ou CE en contre garantie<br />' +
                                                                       '• Accord Engagements si repreneur est une création';
}