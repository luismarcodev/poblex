-- A form deletion cascades to both its submissions and its fields. Answers
-- reference both branches, so the field relation must cascade as well; a
-- restrictive relation makes any submitted form impossible to delete.
ALTER TABLE "form_answers"
DROP CONSTRAINT "form_answers_field_id_fkey";

ALTER TABLE "form_answers"
ADD CONSTRAINT "form_answers_field_id_fkey"
FOREIGN KEY ("field_id") REFERENCES "form_fields"("id")
ON DELETE CASCADE ON UPDATE CASCADE;
