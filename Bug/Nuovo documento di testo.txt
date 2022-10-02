disattivata funzione function disattivaEditSelez(handles), Non funzionava
    inutile per il momento

add:
    in function lb_exp_Callback
      if EnbDisSelez(handles) per evitare errori di aggiornamento finestre etc

    replaced disattivaEditSelez(handles) con EnbDisSelez(handles)

        


create: 
    function EnbDisSelez(handles) %controlla se nell'asse selezionato ci sono segnali e abilita o disabilita alcuni obj
    function refreshLinestyle(handles, tTHk, sQuant) aggiorna il pannello linee con i valori della traccia selezionata
    function defineLineStyle(handles, UD, sF, sQuant) legge i valori di tutti i campi e li mette nelle tTH


mod:
    function tAx = crea_tAx(handles,tAx, tAssi, tTH, sXquant) modificata per permettere le opzioni Msize Mstyle