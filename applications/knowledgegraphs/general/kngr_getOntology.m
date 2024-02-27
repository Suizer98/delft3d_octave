function ontology = getOntology

ontology(01).type    = 'cau';
ontology(01).color   = 'r';
ontology(01).oneway  = 1;
ontology(01).txtin   = ' is influenced by ';
ontology(01).txtout  = ' influences ';

ontology(02).type    = 'sub';
ontology(02).color   = 'g';
ontology(02).oneway  = 1;
ontology(02).txtin   = ' can be a ';
ontology(02).txtout  = ' is some kind of ';

ontology(03).type    = 'ali';
ontology(03).color   = 'b';
ontology(03).oneway  = 0;
ontology(03).txtin   = ' is like ';
ontology(03).txtout  = ' is like ';

ontology(04).type    = 'par';
ontology(04).color   = 'g';
ontology(04).oneway  = 1;
ontology(04).txtin   = ' is said to be ';
ontology(04).txtout  = ' is given to ';

ontology(05).type    = 'equ';
ontology(05).color   = 'k';
ontology(05).oneway  = 0;
ontology(05).txtin   = ' is a ';
ontology(05).txtout  = ' is a ';

ontology(06).type    = 'dis';
ontology(06).color   = 'k';
ontology(06).oneway  = 0;
ontology(06).txtin   = ' nothing like ';
ontology(06).txtout  = ' nothing like ';

ontology(07).type    = 'ord';
ontology(07).color   = 'y';
ontology(07).oneway  = 1;
ontology(07).txtin   = ' after ';
ontology(07).txtout  = ' before ';

ontology(08).type    = 'sko';
ontology(08).color   = 'b';
ontology(08).oneway  = 0;
ontology(08).txtin   = ' all ';
ontology(08).txtout  = ' all ';

ontology(09).type    = 'fpar';
ontology(09).color   = 'k';
ontology(09).oneway  = 1;
ontology(09).txtin   = ' belongs to ';
ontology(09).txtout  = ' contains ';

ontology(10).type    = 'nfpar';
ontology(10).color   = 'k';
ontology(10).oneway  = 1;
ontology(10).txtin   = ' does not belong to ';
ontology(10).txtout  = ' is not ';

ontology(11).type    = 'pospar';
ontology(11).color   = 'k';
ontology(11).oneway  = 1;
ontology(11).txtin   = ' possibly belongs to ';
ontology(11).txtout  = ' can be ';

ontology(12).type    = 'necpar';
ontology(12).color   = 'k';
ontology(12).oneway  = 1;
ontology(12).txtin   = ' necessarily belongs to ';
ontology(12).txtout  = ' is necessary ';

ontology(13).type    = 'ass';
ontology(13).color   = 'k';
ontology(13).oneway  = 1;
ontology(13).txtin   = ' is associated with ';
ontology(13).txtout  = ' is associated with ';

ontology(14).type    = 'cau++';
ontology(14).color   = 'r';
ontology(14).oneway  = 1;
ontology(14).txtin   = ' increase is caused by increase ';
ontology(14).txtout  = ' increased leads to increase of ';

ontology(15).type    = 'cau+-';
ontology(15).color   = 'r';
ontology(15).oneway  = 1;
ontology(15).txtin   = ' decrease is caused by increase ';
ontology(15).txtout  = ' increased leads to decrease of ';

ontology(16).type    = 'cau-+';
ontology(16).color   = 'r';
ontology(16).oneway  = 1;
ontology(16).txtin   = ' increase is caused by decrease ';
ontology(16).txtout  = ' decreased leads to increase of ';

ontology(17).type    = 'cau--';
ontology(17).color   = 'r';
ontology(17).oneway  = 1;
ontology(17).txtin   = ' decrease is caused by decrease ';
ontology(17).txtout  = ' decreased leads to decrease of ';
