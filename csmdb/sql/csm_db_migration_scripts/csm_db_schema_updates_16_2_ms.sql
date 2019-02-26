--===============================================================================
--
--   csm_db_schema_updates_16_2_ms.sql
--
-- © Copyright IBM Corporation 2015-2018. All Rights Reserved
--
--   This program is licensed under the terms of the Eclipse Public License
--   v1.0 as published by the Eclipse Foundation and available at
--   http://www.eclipse.org/legal/epl-v10.html
--
--   U.S. Government Users Restricted Rights:  Use, duplication or disclosure
--   restricted by GSA ADP Schedule Contract with IBM Corp.
--
--===============================================================================

--===============================================================================
--   usage:         ./csm_db_schema_version_upgrade_16_2.sh
--   Purpose:		Upgrades associated with DB schema 16.1
--===============================================================================

SET client_min_messages TO WARNING;
\set ON_ERROR_STOP on
BEGIN;

------------------------------------------
-- Adding in comments to the
-- compute_node_states
-- Adding in the actual value in
-- migration script do to non compatibility
-- within a transition block.
------------------------------------------
COMMENT ON COLUMN csm_node.state is 'state of the node - DISCOVERED, IN_SERVICE, ADMIN_RESERVED, MAINTENANCE, SOFT_FAILURE, OUT_OF_SERVICE, HARD_FAILURE';
COMMENT ON COLUMN csm_node_history.state is 'state of the node - DISCOVERED, IN_SERVICE, ADMIN_RESERVED, MAINTENANCE, SOFT_FAILURE, OUT_OF_SERVICE, HARD_FAILURE';
COMMENT ON COLUMN csm_node_state_history.state is 'state of the node - DISCOVERED, IN_SERVICE, ADMIN_RESERVED, MAINTENANCE, SOFT_FAILURE, OUT_OF_SERVICE, HARD_FAILURE';
COMMENT ON COLUMN csm_ras_type.set_state is 'setting the state according to the node, DISCOVERED, IN_SERVICE, ADMIN_RESERVED, MAINTENANCE, SOFT_FAILURE, OUT_OF_SERVICE, HARD_FAILURE';
COMMENT ON COLUMN csm_ras_type_audit.set_state is 'setting the state according to the node, DISCOVERED, IN_SERVICE, ADMIN_RESERVED, MAINTENANCE, SOFT_FAILURE, OUT_OF_SERVICE, HARD_FAILURE';
-----------------------------------------------------------
-- compute_node_states TYPE comments
-----------------------------------------------------------
--COMMENT ON TYPE compute_node_states IS 'compute_node_states type to help identify the states of the compute nodes';
-------------------------------------------
-- Drop these indexes as they are covered
-- within the primary keys (autogenerated)
-------------------------------------------
DROP INDEX IF EXISTS ix_csm_processor_socket_a;               -- primary keys (autogenerated)
DROP INDEX IF EXISTS ix_csm_switch_a;                         -- primary keys (autogenerated)

-------------------------------------------
-- 16.2 db indexes
-------------------------------------------

DO $$
BEGIN
    BEGIN
        CREATE INDEX ix_csm_allocation_history_b ON csm_allocation_history (allocation_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_allocation_history_b '' on csm_allocation_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_allocation_history_c ON csm_allocation_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_allocation_history_c '' on csm_allocation_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_allocation_history_d ON csm_allocation_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_allocation_history_d '' on csm_allocation_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_allocation_node_history_b ON csm_allocation_node_history (allocation_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_allocation_node_history_b '' on csm_allocation_node_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_allocation_node_history_c ON csm_allocation_node_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_allocation_node_history_c '' on csm_allocation_node_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_allocation_node_history_d ON csm_allocation_node_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_allocation_node_history_d '' on csm_allocation_node_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_allocation_state_history_b ON csm_allocation_state_history (allocation_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_allocation_state_history_b '' on csm_allocation_state_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_allocation_state_history_c ON csm_allocation_state_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_allocation_state_history_c '' on csm_allocation_state_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_allocation_state_history_d ON csm_allocation_state_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_allocation_state_history_d '' on csm_allocation_state_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_config_history_b ON csm_config_history (csm_config_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_config_history_b '' on csm_config_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_config_history_c ON csm_config_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_config_history_c '' on csm_config_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_config_history_d ON csm_config_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_config_history_d '' on csm_config_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_db_schema_version_history_b ON csm_db_schema_version_history (version);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_db_schema_version_history_b '' on csm_db_schema_version_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_db_schema_version_history_c ON csm_db_schema_version_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_db_schema_version_history_c '' on csm_db_schema_version_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_db_schema_version_history_d ON csm_db_schema_version_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_db_schema_version_history_d '' on csm_db_schema_version_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_diag_result_history_b ON csm_diag_result_history (run_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_diag_result_history_b '' on csm_diag_result_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_diag_result_history_c ON csm_diag_result_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_diag_result_history_c '' on csm_diag_result_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_diag_result_history_d ON csm_diag_result_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_diag_result_history_d '' on csm_diag_result_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_diag_run_history_b ON csm_diag_run_history (run_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_diag_run_history_b '' on csm_diag_run_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_diag_run_history_c ON csm_diag_run_history (allocation_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_diag_run_history_c '' on csm_diag_run_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_diag_run_history_d ON csm_diag_run_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_diag_run_history_d '' on csm_diag_run_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_diag_run_history_e ON csm_diag_run_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_diag_run_history_e '' on csm_diag_run_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_dimm_history_b ON csm_dimm_history (node_name, serial_number);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_dimm_history_b '' on csm_dimm_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_dimm_history_c ON csm_dimm_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_dimm_history_c '' on csm_dimm_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_dimm_history_d ON csm_dimm_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_dimm_history_d '' on csm_dimm_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_gpu_history_c ON csm_gpu_history (node_name, gpu_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_gpu_history_c '' on csm_gpu_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_gpu_history_d ON csm_gpu_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_gpu_history_d '' on csm_gpu_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_gpu_history_e ON csm_gpu_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_gpu_history_e '' on csm_gpu_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_hca_history_b ON csm_hca_history (node_name, serial_number);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_hca_history_b '' on csm_hca_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_hca_history_c ON csm_hca_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_hca_history_c '' on csm_hca_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_hca_history_d ON csm_hca_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_hca_history_d '' on csm_hca_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_ib_cable_history_b ON csm_ib_cable_history (serial_number);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_ib_cable_history_b '' on csm_ib_cable_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_ib_cable_history_c ON csm_ib_cable_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_ib_cable_history_c '' on csm_ib_cable_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_ib_cable_history_d ON csm_ib_cable_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_ib_cable_history_d '' on csm_ib_cable_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_lv_history_c ON csm_lv_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_lv_history_c '' on csm_lv_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_lv_history_d ON csm_lv_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_lv_history_d '' on csm_lv_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_lv_update_history_c ON csm_lv_update_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_lv_update_history_c '' on csm_lv_update_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_lv_update_history_d ON csm_lv_update_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_lv_update_history_d '' on csm_lv_update_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_node_history_c ON csm_node_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_node_history_c '' on csm_node_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_node_history_d ON csm_node_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_node_history_d '' on csm_node_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_node_state_history_c ON csm_node_state_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_node_state_history_c '' on csm_node_state_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_node_state_history_d ON csm_node_state_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_node_state_history_d '' on csm_node_state_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_processor_socket_history_c ON csm_processor_socket_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_processor_socket_history_c '' on csm_processor_socket_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_processor_socket_history_d ON csm_processor_socket_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_processor_socket_history_d '' on csm_processor_socket_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_ras_event_action_f ON csm_ras_event_action (master_time_stamp);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_ras_event_action_f '' on csm_ras_event_action already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_ras_event_action_g ON csm_ras_event_action (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_ras_event_action_g '' on csm_ras_event_action already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_ras_event_action_h ON csm_ras_event_action (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_ras_event_action_h '' on csm_ras_event_action already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_ssd_history_c ON csm_ssd_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_ssd_history_c '' on csm_ssd_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_ssd_history_d ON csm_ssd_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_ssd_history_d '' on csm_ssd_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_ssd_wear_history_c ON csm_ssd_wear_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_ssd_wear_history_c '' on csm_ssd_wear_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_ssd_wear_history_d ON csm_ssd_wear_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_ssd_wear_history_d '' on csm_ssd_wear_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_step_history_f ON csm_step_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_step_history_f '' on csm_step_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_step_history_g ON csm_step_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_step_history_g '' on csm_step_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_step_node_b ON csm_step_node (allocation_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_step_node_b '' on csm_step_node already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_step_node_c ON csm_step_node (allocation_id, step_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_step_node_c '' on csm_step_node already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_step_node_history_b ON csm_step_node_history (allocation_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_step_node_history_b '' on csm_step_node_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_step_node_history_c ON csm_step_node_history (allocation_id, step_id);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_step_node_history_c '' on csm_step_node_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_step_node_history_d ON csm_step_node_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_step_node_history_d '' on csm_step_node_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_step_node_history_e ON csm_step_node_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_step_node_history_e '' on csm_step_node_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_switch_history_c ON csm_switch_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_switch_history_c '' on csm_switch_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_switch_history_d ON csm_switch_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_switch_history_d '' on csm_switch_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_switch_inventory_history_b ON csm_switch_inventory_history (name);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_switch_inventory_history_b '' on csm_switch_inventory_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_switch_inventory_history_c ON csm_switch_inventory_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_switch_inventory_history_c '' on csm_switch_inventory_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_switch_inventory_history_d ON csm_switch_inventory_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_switch_inventory_history_d '' on csm_switch_inventory_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_vg_history_b ON csm_vg_history (vg_name, node_name);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_vg_history_b '' on csm_vg_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_vg_history_c ON csm_vg_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_vg_history_c '' on csm_vg_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_vg_history_d ON csm_vg_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_vg_history_d '' on csm_vg_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        CREATE INDEX ix_csm_vg_ssd_history_b ON csm_vg_ssd_history (vg_name, node_name);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_vg_ssd_history_b '' on csm_vg_ssd_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_vg_ssd_history_c ON csm_vg_ssd_history (ctid);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_vg_ssd_history_c '' on csm_vg_ssd_history already exists, skipping';
    END;
    BEGIN
        CREATE INDEX ix_csm_vg_ssd_history_d ON csm_vg_ssd_history (archive_history_time);
    EXCEPTION
        WHEN duplicate_table
        THEN RAISE NOTICE 'index ''ix_csm_vg_ssd_history_d '' on csm_vg_ssd_history already exists, skipping';
    END;
    ------------------------------------------------------------------------------------------------------------------------------
END;
$$;

-------------------------------------------------------------------------------------------------------------
-- Now process all the comments related to the indexes (comments)
-------------------------------------------------------------------------------------------------------------
-- csm_allocation_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_allocation_history_b IS 'index on allocation_id';
COMMENT ON INDEX ix_csm_allocation_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_allocation_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_allocation_node_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_allocation_node_history_b IS 'index on allocation_id';
COMMENT ON INDEX ix_csm_allocation_node_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_allocation_node_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_allocation_node_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_allocation_node_history_b IS 'index on allocation_id';
COMMENT ON INDEX ix_csm_allocation_node_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_allocation_node_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_allocation_state_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_allocation_state_history_b IS 'index on allocation_id';
COMMENT ON INDEX ix_csm_allocation_state_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_allocation_state_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_config_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_config_history_b IS 'index on csm_config_id';
COMMENT ON INDEX ix_csm_config_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_config_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_db_schema_version_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_db_schema_version_history_b IS 'index on version';
COMMENT ON INDEX ix_csm_db_schema_version_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_db_schema_version_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_diag_result_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_diag_result_history_b IS 'index on run_id';
COMMENT ON INDEX ix_csm_diag_result_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_diag_result_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_diag_run_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_diag_run_history_b IS 'index on run_id';
COMMENT ON INDEX ix_csm_diag_run_history_c IS 'index on allocation_id';
COMMENT ON INDEX ix_csm_diag_run_history_d IS 'index on ctid';
COMMENT ON INDEX ix_csm_diag_run_history_e IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_dimm_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_dimm_history_b IS 'index on node_name, serial_number';
COMMENT ON INDEX ix_csm_dimm_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_dimm_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_gpu_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_gpu_history_c IS 'index on node_name, gpu_id';
COMMENT ON INDEX ix_csm_gpu_history_d IS 'index on ctid';
COMMENT ON INDEX ix_csm_gpu_history_e IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_hca_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_hca_history_b IS 'index on node_name, serial_number';
COMMENT ON INDEX ix_csm_hca_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_hca_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_ib_cable_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_ib_cable_history_b IS 'index on serial_number';
COMMENT ON INDEX ix_csm_ib_cable_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_ib_cable_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_lv_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_lv_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_lv_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_lv_update_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_lv_update_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_lv_update_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_node_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_node_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_node_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_node_state_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_node_state_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_node_state_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_processor_socket_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_processor_socket_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_processor_socket_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_ras_event_action (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_ras_event_action_f IS 'index on master_time_stamp';
COMMENT ON INDEX ix_csm_ras_event_action_g IS 'index on ctid';
COMMENT ON INDEX ix_csm_ras_event_action_h IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_ssd_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_ssd_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_ssd_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_ssd_wear_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_ssd_wear_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_ssd_wear_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_step_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_step_history_f IS 'index on ctid';
COMMENT ON INDEX ix_csm_step_history_g IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_step_node (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_step_node_b IS 'index on allocation_id';
COMMENT ON INDEX ix_csm_step_node_c IS 'index on allocation_id, step_id';
-------------------------------------------------------------------------------------------------------------
-- csm_step_node_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_step_node_history_b IS 'index on allocation_id';
COMMENT ON INDEX ix_csm_step_node_history_c IS 'index on allocation_id, step_id';
COMMENT ON INDEX ix_csm_step_node_history_d IS 'index on ctid';
COMMENT ON INDEX ix_csm_step_node_history_e IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_switch_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_switch_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_switch_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_switch_inventory_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_switch_inventory_history_b IS 'index on name';
COMMENT ON INDEX ix_csm_switch_inventory_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_switch_inventory_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_vg_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_vg_history_b IS 'vg_name, node_name';
COMMENT ON INDEX ix_csm_vg_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_vg_history_d IS 'index on archive_history_time';
-------------------------------------------------------------------------------------------------------------
-- csm_vg_ssd_history (comments)
-------------------------------------------------------------------------------------------------------------
COMMENT ON INDEX ix_csm_vg_ssd_history_b IS 'vg_name, node_name';
COMMENT ON INDEX ix_csm_vg_ssd_history_c IS 'index on ctid';
COMMENT ON INDEX ix_csm_vg_ssd_history_d IS 'index on archive_history_time';

COMMIT;
