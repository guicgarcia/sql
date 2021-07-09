CREATE DEFINER=`root`@`localhost` EVENT `cadastrarAtrasados` ON SCHEDULE EVERY 1 MINUTE STARTS '2020-06-14 10:33:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN

DECLARE userId INT;
DECLARE contadorId INT;
DECLARE registroPonts INT;
DECLARE fimloop INT DEFAULT FALSE;

DECLARE meucursor CURSOR FOR SELECT id FROM users WHERE curtime() > entrada;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET fimloop = TRUE;

OPEN meucursor;

read_loop: LOOP
    FETCH meucursor INTO userId;
    IF fimloop THEN
      LEAVE read_loop;
    END IF;

    SELECT COUNT(id) INTO contadorId FROM ponts 
    WHERE user_id = userId AND DATE_FORMAT(created,'%y-%m-%d') = CURDATE()
    ORDER BY id DESC LIMIT 1;
    
    IF contadorId = 0 THEN
        SELECT count(id) INTO registroPonts FROM ponts 
        WHERE user_id = userId AND DATE_FORMAT(created,'%y-%m-%d') = CURDATE() AND faltou = 1
        ORDER BY id DESC LIMIT 1;
        
        IF registroPonts = 0 THEN
            insert into ponts (faltou, user_id, created) value (1, userId, NOW());
        END IF;
        
    else
        select('Já entrou');
    END IF;
    
END LOOP;

CLOSE meucursor;
    
END