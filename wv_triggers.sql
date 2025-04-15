-- 1. Trigger pour exécuter la procédure COMPLETE_TOUR quand un tour est marqué comme terminé
CREATE OR REPLACE FUNCTION complete_tour_trigger_fn()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM COMPLETE_TOUR(NEW.id, NEW.party_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER complete_tour_trigger
AFTER UPDATE OF status ON tours
FOR EACH ROW
WHEN (NEW.status = 'completed' AND OLD.status != 'completed')
EXECUTE FUNCTION complete_tour_trigger_fn();

-- 2. Trigger pour exécuter la procédure USERNAME_TO_LOWER lors de l'inscription d'un joueur
CREATE OR REPLACE FUNCTION username_to_lower_trigger_fn()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM USERNAME_TO_LOWER();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER username_to_lower_trigger
AFTER INSERT ON players
FOR EACH ROW
EXECUTE FUNCTION username_to_lower_trigger_fn();