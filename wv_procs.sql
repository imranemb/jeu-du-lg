-- 1. Procédure SEED_DATA : Crée les tours de jeu pour une partie donnée
CREATE OR REPLACE PROCEDURE SEED_DATA(NB_PLAYERS INT, PARTY_ID INT)
LANGUAGE plpgsql AS $$
DECLARE
    total_turns INT;
BEGIN
    total_turns := NB_PLAYERS * 2;

    FOR i IN 1..total_turns LOOP
        INSERT INTO tours (party_id, tour_number)
        VALUES (PARTY_ID, i);
    END LOOP;
END;
$$;

-- 2. Procédure COMPLETE_TOUR : Applique les déplacements des joueurs et résout les conflits
CREATE OR REPLACE PROCEDURE COMPLETE_TOUR(TOUR_ID INT, PARTY_ID INT)
LANGUAGE plpgsql AS $$
DECLARE
    conflict_count INT;
BEGIN
    SELECT COUNT(*) INTO conflict_count
    FROM moves
    WHERE tour_id = TOUR_ID
      AND position IN (SELECT position FROM moves WHERE tour_id = TOUR_ID GROUP BY position HAVING COUNT(*) > 1);

    IF conflict_count > 0 THEN
        RAISE NOTICE 'Conflits détectés pour le tour %', TOUR_ID;
        UPDATE moves
        SET is_valid = FALSE
        WHERE tour_id = TOUR_ID
          AND position IN (SELECT position FROM moves WHERE tour_id = TOUR_ID GROUP BY position HAVING COUNT(*) > 1);
    END IF;

    UPDATE players
    SET position = m.position
    FROM moves m
    WHERE m.tour_id = TOUR_ID
      AND m.player_id = players.id
      AND m.is_valid = TRUE;
    
    UPDATE tours
    SET status = 'completed'
    WHERE id = TOUR_ID;
END;
$$;

-- 3. Procédure USERNAME_TO_LOWER : Met tous les noms de joueurs en minuscules
CREATE OR REPLACE PROCEDURE USERNAME_TO_LOWER()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE players
    SET name = LOWER(name);
END;
$$;