-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.users (
  user_id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  role text NOT NULL CHECK (role IN ('student', 'instructor', 'admin')),
  created_at timestamp with time zone DEFAULT now(),
  password_hash text,
  CONSTRAINT users_pkey PRIMARY KEY (user_id)
);

CREATE TABLE public.assignments (
  assignment_id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  created_by uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  due_date timestamp with time zone,
  CONSTRAINT assignments_pkey PRIMARY KEY (assignment_id),
  CONSTRAINT assignments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(user_id),
  CONSTRAINT assignments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(user_id) ON DELETE RESTRICT
);

CREATE TABLE public.assignment_students (
  assignment_id uuid REFERENCES assignments(assignment_id),
  student_id uuid REFERENCES users(user_id),
  PRIMARY KEY (assignment_id, student_id),
  CONSTRAINT assignment_students_assignment_fkey FOREIGN (assignment_id) REFERENCES public.assignments(assignment_id) ON DELETE CASCADE,
  CONSTRAINT assignment_students_student_fkey FOREIGN KEY (student_id) REFERENCES public.users(user_id) ON DELETE CASCADE
);

CREATE TABLE public.chat_memory (
  chat_id uuid NOT NULL DEFAULT gen_random_uuid(),
  assignment_id uuid,
  user_id uuid NULL,
  sender_type text NOT NULL CHECK (
    (sender_type = 'system' AND user_id IS NULL)
    OR
    (sender_type IN ('student','instructor') AND user_id IS NOT NULL)
    ),
  message_text text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT chat_memory_pkey PRIMARY KEY (chat_id),
  CONSTRAINT chat_memory_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(assignment_id) ON DELETE SET NULL,
  CONSTRAINT chat_memory_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE SET NULL,
);

CREATE TABLE public.student_reflections (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  chat_id uuid,
  assignment_id uuid,
  reflection_text text NOT NULL,
  confidence_rating integer CHECK (confidence_rating >= 1 AND confidence_rating <= 5),
  difficulty_rating integer CHECK (difficulty_rating >= 1 AND difficulty_rating <= 5),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT student_reflections_pkey PRIMARY KEY (id),
  CONSTRAINT student_reflections_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(user_id) ON DELETE CASCADE,
  CONSTRAINT student_reflections_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.chat_memory(chat_id) ON DELETE CASCADE,
  CONSTRAINT student_reflections_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(assignment_id) ON DELETE CASCADE
);

CREATE TABLE public.reflection_analysis (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  reflection_id uuid NOT NULL,
  confidence_score integer NOT NULL CHECK (confidence_score >= 1 AND confidence_score <= 5),
  understanding_score integer NOT NULL CHECK (understanding_score >= 1 AND understanding_score <= 5),
  difficulty_score integer NOT NULL CHECK (difficulty_score >= 1 AND difficulty_score <= 5),
  analysis_explanation text,
  analyzed_at timestamp with time zone DEFAULT now(),
  CONSTRAINT reflection_analysis_pkey PRIMARY KEY (id),
  CONSTRAINT reflection_analysis_reflection_id_fkey FOREIGN KEY (reflection_id) REFERENCES public.student_reflections(id) ON DELETE CASCADE
);

CREATE TABLE public.student_performance_metrics (
  student_id uuid NOT NULL,
  accuracy real DEFAULT 0.0 CHECK (accuracy >= 0.0::double precision AND accuracy <= 1.0::double precision),
  hint_count integer DEFAULT 0,
  struggles integer DEFAULT 0,
  tasks_completed integer DEFAULT 0,
  time_spent real DEFAULT 0.0,
  confidence_level text GENERATED ALWAYS AS (
    CASE
        WHEN accuracy > 0.8 THEN 'high'
        WHEN accuracy > 0.5 THEN 'medium'
        ELSE 'low'
    END
    ) STORED,
  current_difficulty integer DEFAULT 1 CHECK (current_difficulty >= 1 AND current_difficulty <= 5),
  difficulty text,
  support_level integer DEFAULT 2 CHECK (support_level >= 1 AND support_level <= 3),
  last_updated timestamp with time zone DEFAULT now(),
  CONSTRAINT student_performance_metrics_pkey PRIMARY KEY (student_id),
  CONSTRAINT student_performance_metrics_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(user_id) ON DELETE CASCADE
);

CREATE TABLE public.student_state_changes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  change_type text NOT NULL CHECK (change_type IN (
    'difficulty_adjustment',
    'support_level_change',
    'confidence_update'
    )),
  old_values jsonb,
  new_values jsonb,
  triggered_by text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT student_state_changes_pkey PRIMARY KEY (id),
  CONSTRAINT student_state_changes_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(user_id) ON DELETE CASCADE
);

ALTER TABLE users ADD COLUMN is_active boolean DEFAULT true;
