SHOW VARIABLES LIKE 'event%';
SET GLOBAL event_scheduler = ON;

DELIMITER //
CREATE EVENT update_monthly_depreciation
ON SCHEDULE EVERY 1 MONTH
STARTS '2021-7-25'
DO BEGIN

   /** 
    * Todo mês é atualizado: 
    * 1) O total de meses em que o equipamento depreciou (esteve em uso)
    * 2) O valor total que o equipamento depreciou 
    * 3) O total de meses em que o equipamento ficou guardado na RHB
    * 
    * Obs: Um equipamento deprecia apenas 36 meses.
    *      O equipamento começa a depreciar a partir do momente em que é cadastrado um número de nota fiscal.
    *      O equipamento precisa estar associado a um cliente que não seja o cliente RHB de id = 1.
    */

    DECLARE fimloop INT DEFAULT FALSE; 
    DECLARE valorCompra DOUBLE;
    DECLARE taxaDepreciacao DOUBLE;
    
    DECLARE meucursor CURSOR FOR SELECT valor_compra FROM equipaments;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fimloop = TRUE;
    
    OPEN meucursor;

	read_loop: LOOP
	FETCH meucursor INTO valorCompra, numeroNotaFiscal;
		IF fimloop THEN
		  LEAVE read_loop;
		END IF;
        
        /*Atualização mensal da quantidade de meses depreciados.*/
	UPDATE equipaments SET meses_depreciacao = meses_depreciacao + 1 
        WHERE meses_depreciacao <= 35 AND numero_nota_fiscal != null AND client_id != 1 AND ;
    
        /*Taxa de depreciação mensal*/
	SET taxaDepreciacao = valorCompra / 36 ;
        /*Atualização mensal do valor total depreciado.*/
        UPDATE equipaments SET total_valor_depreciacao = total_valor_depreciacao + taxaDepreciacao 
        WHERE meses_depreciacao <= 35 AND numero_nota_fiscal != null AND client_id != 1;
		
        /*Atualização mensal da quantidade de meses em que o equipamento ficou guardado no estoque.*/
	UPDATE equipaments SET meses_guardado_rhb = meses_guardado_rhb + 1 
        WHERE meses_depreciacao <= 35 AND client_id = 1;
	END LOOP;

	CLOSE meucursor;

END//
DELIMITER ;

SHOW EVENTS FROM db;
DROP EVENT update_monthly_depreciation;
