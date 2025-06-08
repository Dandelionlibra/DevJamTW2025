CREATE TABLE public.vector_store (
    id bigint primary key generated always as identity,
    vector bytea NOT NULL
) WITH (OIDS=FALSE);

ALTER TABLE public.vector_store ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to select from vector_store" 
ON public.vector_store 
FOR SELECT 
TO authenticated 
USING ((select auth.uid()) IS NOT NULL);

CREATE POLICY "Allow authenticated users to insert into vector_store" 
ON public.vector_store 
FOR INSERT 
TO authenticated 
WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update vector_store" 
ON public.vector_store 
FOR UPDATE 
TO authenticated 
USING ((select auth.uid()) IS NOT NULL) 
WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete from vector_store" 
ON public.vector_store 
FOR DELETE 
TO authenticated 
USING ((select auth.uid()) IS NOT NULL);


CREATE TABLE public.food_categories (
    id bigint primary key generated always as identity,
    name text NOT NULL,
    vector_id bigint NOT NULL,
    FOREIGN KEY (vector_id) REFERENCES public.vector_store(id)
) WITH (OIDS=FALSE);

ALTER TABLE public.food_categories ENABLE ROW LEVEL SECURITY;