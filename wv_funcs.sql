-- Fonction 1
CREATE OR REPLACE FUNCTION random_position(party_id INT)
RETURNS TABLE(pos_x INT, pos_y INT) AS $$
DECLARE
    max_x INT;
    max_y INT;
    try_x INT;
    try_y INT;
BEGIN
    SELECT grid_width, grid_height
    INTO max_x, max_y
    FROM parties
    WHERE id = party_id;

    LOOP
        try_x := floor(random() * max_x)::INT;
        try_y := floor(random() * max_y)::INT;

        IF NOT EXISTS (
            SELECT 1 FROM players
            WHERE party_id = random_position.party_id
              AND pos_x = try_x
              AND pos_y = try_y
        ) THEN
            pos_x := try_x;
            pos_y := try_y;
            RETURN NEXT;
            RETURN;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Fonction 2
CREATE OR REPLACE FUNCTION random_role(party_id INT)
RETURNS TEXT AS $$
DECLARE
    total_players INT;
    wolves_count INT;
    wolves_assigned INT;
    villagers_assigned INT;
BEGIN
    SELECT expected_player_count INTO total_players FROM parties WHERE id = party_id;

    wolves_count := ceil(total_players * 0.25)::INT;

    SELECT COUNT(*) INTO wolves_assigned FROM players WHERE party_id = party_id AND role = 'loup';
    SELECT COUNT(*) INTO villagers_assigned FROM players WHERE party_id = party_id AND role = 'villageois';

    IF wolves_assigned < wolves_count THEN
        RETURN 'loup';
    ELSE
        RETURN 'villageois';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Fonction 3 
CREATE OR REPLACE FUNCTION get_the_winner(party_id INT)
RETURNS TABLE (
    player_name TEXT,
    role TEXT,
    party_name TEXT,
    turns_played INT,
    total_turns INT,
    avg_decision_time INTERVAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.name,
        p.role,
        pt.name,
        COUNT(DISTINCT a.turn_id),
        pt.total_turns,
        AVG(a.decision_time)
    FROM players p
    JOIN parties pt ON pt.id = p.party_id
    LEFT JOIN actions a ON a.player_id = p.id
    WHERE p.party_id = party_id AND p.is_winner = TRUE
    GROUP BY p.id, p.name, p.role, pt.name, pt.total_turns;
END;
$$ LANGUAGE plpgsql;