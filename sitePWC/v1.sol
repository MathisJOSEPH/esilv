//test abi -> fonctions principales, pas de privilièges


pragma solidity ^0.4.19;

//cet import est nécessaire pour la fonction concatenation
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract Stock{
    using strings for *;
    
	struct Etape{
	    string intitule;
		string lieu;
		string date;
		Acteur proprietaire;
		//string certification;
	}

	struct Lot{
		string ref_produit;
		string ref_lot;
		uint[] historique;
		mapping(uint=>Etape) Structure_Etape;//On est obligé de passer par un mapping car solidity ne supporte pas encore les listes de struct
	}

	struct Acteur
	{
		address adresse;
		string nom;
		uint privilege;
	}


    
	address public Auchan=0x8c44A3E6CCEb9fa4b19b3Db18D79F2C2737e39a8;//adresse de la personne à a tete de la BC
	mapping(uint=>Lot) Structure_Lot;
	mapping(address=>Acteur) Acteurs;
	uint[] public inventaire;//liste des clefs de lot
	
    function Stock() public
    {
        Acteurs[Auchan].adresse=Auchan;
        Acteurs[Auchan].nom="ADMINISTRATEUR";
        Acteurs[Auchan].privilege=1;
    }
	
	
	function Nouvel_Acteur(address _adresse, string _nom, uint _privilege) public acteur_existant(_adresse)//Permet de créer un nouvel acteur comme le désire un administrateur
	{
		Acteurs[_adresse].adresse=_adresse;
		Acteurs[_adresse].nom=_nom;
		Acteurs[_adresse].privilege=_privilege;
	}
	
	function Modifier_Acteur(address _adresse, string _nom, uint _privilege) public// privilege_1()//un administrateur a le droit de modifier les infos d'un Acteur
	{
	    Acteurs[_adresse].adresse=_adresse;
		Acteurs[_adresse].nom=_nom;
		Acteurs[_adresse].privilege=_privilege;
	}
	
	function Nouveau_Lot(string _ref_produit, string _ref_lot, string _lieu, string _date) public returns(uint)//Permet de créer un nouveau lot
	{
		uint clef=inventaire.length;//generation de la clef du nouveau lot
		inventaire.push(clef);//on l'ajoute à l'inventaire
	    Structure_Lot[clef].ref_produit=_ref_produit;
	    Structure_Lot[clef].ref_lot=_ref_lot;

	    
	    //etape genesis, ajoutée lors de la création du lot
	    uint clef_etape=Structure_Lot[clef].historique.length;//generation de la clef_etape
	    Structure_Lot[clef].historique.push(clef_etape);//on l'ajoute à historique
	    Structure_Lot[clef].Structure_Etape[clef_etape].intitule="Création";
	    Structure_Lot[clef].Structure_Etape[clef_etape].lieu=_lieu;
	    Structure_Lot[clef].Structure_Etape[clef_etape].date=_date;
	    
	    Acteur storage  _nouvel_acteur = Acteurs[msg.sender];//on récupere le nouvel acteur à partir de son address
	    Structure_Lot[clef].Structure_Etape[clef_etape].proprietaire=_nouvel_acteur;

	    //Structure_Lot[clef].Structure_Etape[clef_etape].certification=concatenation("","");
	    
	    return clef;
    }

	function Ajouter_Etape(uint clef_lot, string _intitule,  string _lieu, string _date, address _nouveau_proprietaire) public returns (bool)//Permet de créer une nouvelle etape
	{
	    uint clef_etape=Structure_Lot[clef_lot].historique.length;//generation de la clef_etape
	    Structure_Lot[clef_lot].historique.push(clef_etape);//on l'ajoute à historique
	    Structure_Lot[clef_lot].Structure_Etape[clef_etape].lieu=_lieu;
	    Structure_Lot[clef_lot].Structure_Etape[clef_etape].date=_date;
	    
	    if (keccak256(_intitule)==keccak256("Certification"))
	    {
	        _intitule=concatenation(_intitule, " by ");
	        _intitule=concatenation(_intitule, Acteurs[msg.sender].nom);
	        
	        Structure_Lot[clef_lot].Structure_Etape[clef_etape].proprietaire=Structure_Lot[clef_lot].Structure_Etape[clef_etape-1].proprietaire;
	    }
	    else
	    {
	        Acteur storage  _nouvel_acteur = Acteurs[_nouveau_proprietaire];//on récupere le nouvel acteur à partir de son address
	        Structure_Lot[clef_lot].Structure_Etape[clef_etape].proprietaire=_nouvel_acteur;
	    }
	    
	    Structure_Lot[clef_lot].Structure_Etape[clef_etape].intitule=_intitule;
	    
	    
	    return true;
	}


	
	function Get_Lot_refP_Avec_Clef(uint clef) private constant returns(string ref_produit)//renvoie la ref_Produit du lot associé à la clef
	{
	    return(Structure_Lot[clef].ref_produit);
	}
    
    function Get_Lot_refL_Avec_Clef(uint clef) private constant returns(string ref_lot)//renvoie la ref_Lot du lot associé à la clef
	{
	    return(Structure_Lot[clef].ref_lot);
	}
    
    function Get_Etape_intitule_Avec_Clef(uint clef_lot, uint clef_etape) private constant returns(string)
    {
        return (Structure_Lot[clef_lot].Structure_Etape[clef_etape].intitule);
    }

    function Get_Etape_lieu_Avec_Clef(uint clef_lot, uint clef_etape) private constant returns(string)//renvoie le lieu d'une étape précise
	{
	    return (Structure_Lot[clef_lot].Structure_Etape[clef_etape].lieu);
	}
	
	function Get_Etape_date_Avec_Clef(uint clef_lot, uint clef_etape) private constant returns(string)//revoie la date d'une étape précise
	{
	    return (Structure_Lot[clef_lot].Structure_Etape[clef_etape].date);
	}

	function Get_Etape_nom_Avec_Clef(uint clef_lot, uint clef_etape) private constant returns(string)//renvoie le nom du proprietaire du lot à une étape précise
	{
	    return (Structure_Lot[clef_lot].Structure_Etape[clef_etape].proprietaire.nom);
	}
	
	function Get_Etape_adresse_Avec_Clef(uint clef_lot, uint clef_etape) private constant returns(address)//renvoie l'address du proprietaire du lot à une étape précise
	{
	    return (Structure_Lot[clef_lot].Structure_Etape[clef_etape].proprietaire.adresse);
	}



	function Get_Nb_Lot() private constant returns(uint)//renvoie le nombre de lot dans la BC
	{
	    return inventaire.length;
	}
	
	function Get_Clef_Lot(uint index) private constant returns(uint clef_lot)//renvoie la clef du lot stockée à l'index i dans "inventaire" 
	{
	    return inventaire[index];
	}
	
	function Get_Nb_Etape(uint clef_lot) private constant returns(uint)//donne le nombre d'étape dans un lot
	{
	    return Structure_Lot[clef_lot].historique.length;
	}
	
	function Get_clef_Etape(uint clef_lot, uint index) private constant returns(uint)//renvoie la clef d'une étape précise pour un lot précis
	{
	    return Structure_Lot[clef_lot].historique[index];   
	}




	function concatenation(string s1, string s2) private view returns(string)//concatenation de 2 string
	{
    	return s1.toSlice().concat(s2.toSlice());
  	}


  	function histoire(uint clef_lot) public constant returns(string)//de la forme intitule,lieu,date,proprietaire,certification;
  	{
  		string memory res=concatenation("","");
  		uint n=Get_Nb_Etape(clef_lot);

  		for (uint i=0;i<n;i++)
  		{
  		    res=concatenation(res,Get_Etape_intitule_Avec_Clef(clef_lot,i));
  		    res=concatenation(res,",");
  		    
  			res=concatenation(res,Get_Etape_lieu_Avec_Clef(clef_lot,i));
  			res=concatenation(res,",");

  			res=concatenation(res,Get_Etape_date_Avec_Clef(clef_lot,i));
  			res=concatenation(res,",");

  			res=concatenation(res,Get_Etape_nom_Avec_Clef(clef_lot,i));
  			res=concatenation(res,";");

  		}

  		return res;
  	}
    
    function uintToString(uint i) private constant returns (string)//convertis un entier en string
    {
        if (i==0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function info_produit(uint clef_lot) public constant returns(string)//renvoie toutes les infos d'un lot précis
    {
    	string memory res = concatenation("","");

    	res=concatenation(res,uintToString(clef_lot));
    	res=concatenation(res,",");

    	res=concatenation(res,Get_Lot_refP_Avec_Clef(clef_lot));
        res=concatenation(res,",");
                    
        res=concatenation(res,Get_Lot_refL_Avec_Clef(clef_lot));
        res=concatenation(res,";");
        
        return res;
    }

    function utilisateur_est_proprietaire(uint clef_lot, address utilisateur) public constant returns(bool)//renvoie true si utilisateur est proprietaire du lot (=proprietaire de la derniere étape)
    {
    	bool res=true;
    	uint n=Get_Nb_Etape(clef_lot);

    	if (n==0)//on vérifie qu il y a au moins 1 étape
    	{
    		return false;
    	}

    	if (Get_Etape_adresse_Avec_Clef(clef_lot,n-1)!=utilisateur)
    	{
    		res=false;
    	}

    	return res;
    }

    function infos_utilisateur() public constant returns(string)//de la forme clef_lot,ref_Produit,ref_Lot         renvoie toutes les clefs de lot dont utilisateur est proprietaire
    {
        string memory res=concatenation("","");
        uint N=Get_Nb_Lot();
        
        for(uint i=0;i<N;i++)
        {
            if(utilisateur_est_proprietaire(inventaire[i],msg.sender))
            {
                res=concatenation(res,info_produit(inventaire[i]));
            }
        }
        return res;
    }
    
    
    function trouver(string _ref_produit) public constant returns(string)//renvoie toutes les clefs de lot qui ont la bonne ref_Produit
    {
        string memory res=concatenation("","");
        uint N=Get_Nb_Lot();
        for (uint i=0; i<N; i++)
        {
            if (keccak256(Get_Lot_refP_Avec_Clef(inventaire[i]))==keccak256(_ref_produit))
            {
                res=concatenation(res,uintToString(inventaire[i]));
                res=concatenation(res,";");
            }
        }
        return res;
    }
    
    function infos_acteurs(address utilisateur) public constant returns(string)
    {
        string memory res=concatenation("","");
        res=concatenation(res,Acteurs[msg.sender].nom);
        res=concatenation(res,",");
        
        uint  x=Acteurs[utilisateur].privilege;
        string memory privi;
        if (x==1) {privi="Administrateur";}
        else
        {
            if (x==2) {privi="Sous-Traitant";}
            else {privi="Auditeur";}
        }
        
        res=concatenation(res,privi);
        return res;
    }

	
	modifier acteur_existant(address nouvel_acteur)//verifie que l'acteur existe ou non
	{
	    string memory n= concatenation("","");
	    if (keccak256(Acteurs[nouvel_acteur].nom)!=keccak256(n)) revert();//si il existe on sort
	    _;//sinon on continue
	}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

//1 = administrateur
//2 = sous traitant
//3 = audit

	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	modifier isowner()//permet de verifier que celui qui lance la fonction est bien l'administrateur, utile pour que n importe qui ne puisse pas détruire le SC
	{
		if (msg.sender!=Auchan) revert();
		_;
	}

	function kill() isowner() public //destruction du SC
	{
		delete Auchan;
		selfdestruct(msg.sender);
	}
	
}