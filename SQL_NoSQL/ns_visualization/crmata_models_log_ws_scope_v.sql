/*CREATE VIEW [ns_visualization].[crmdata_models_log_ws_scope_v] AS */
select
		v2.sessionid as sessionid,	
			
		-- item details 
		crm.D1SRCCRM_YOPPNMBR as RFQ,
		crm.D1SRCCRM_YSQN as SQN,
		crm.D1SRCCRM_YOPPNMBR + '_' + crm.D1SRCCRM_YSQN as item_id,				
		crm.D1SRCCRM_YOPPTYPE as opportunity_type,
		crm.D1SRCCRM_YPRCPER as price_commitment_period, 
		crm.D1SRCCRM_YOPPTYPE + ' ' + crm.D1SRCCRM_YPRCPER as opportunity_type_and_commitment_period,
		crm.D1SRCCRM_YRPOINS as period_offered,
		crm.D1SRCCRM_YQLISTAT as crm_status,

		-- item cu/csu
		for_cu_encoding.value_code as cu_id,
		for_cu_encoding.value as cu_name,
		for_csu_encoding.value_code as csu_id, 
		for_csu_encoding.value as csu_name,
		supra_region_encoding.value as supraregion,		
		
		-- item family/sector
		family_encoding.value_code as family_id, 
		family_encoding.value as family_name,
		sub_family_encoding.value_code as sub_family_id,
		sub_family_encoding.value as sub_family_name,		
		family_encoding.value + ' ' + for_csu_encoding.value as intersection_name,
		case when failsafe_input.l_par_sf_ys_zzz172 is not null and failsafe_input.yocmat_yodpprfam is not null then 'yes' else 'no' end as rolled_out_intersection,
		sector_encoding.value as sector, 
		
		-- item technical details				
		crm.D1SRCCRM_YCRMQTYT as volume, 
		steel_grade_encoding.value_code as steel_grade_id,
		steel_grade_encoding.value as steel_grade,
		crm.D1SRCCRM_YTHICKNS as thickness,
		crm.D1SRCCRM_YWIDTH as width,
		crm.D1SRCCRM_YTNTIND as top_non_top, 
		
		-- item technical details for OC products
		crm.D1SRCCRM_YCRM_C077 as organic_data_sheet_bottom, 
		crm.D1SRCCRM_YCRMCO52 as organic_data_sheet_top, 
		coating_specification_encoding.value_code as coating_specification_id,
		coating_specification_encoding.value as coating_specification,
		crm.D1SRCCRM_YCRMCO75D as color_cat_top,
		crm.D1SRCCRM_YCRMCO81D as color_cat_bottom,
		crm.D1SRCCRM_YCRMCO78D as color_std_top,
		crm.D1SRCCRM_YCRMCO79D as color_std_bottom,
		case when v2.is_color_bottom_spot = 1 then 'yes' else 'no' end as is_color_bottom_spot,
		case when v2.is_color_top_spot = 1 then 'yes' else 'no' end as is_color_top_spot,

		-- customer and manager
		crm.D1SRCCRM_YCRMSFCC as customer_id, -- l_par_sf
		sector.value as customer_sector, 
		branch.value as customer_branch, 
		crm.D1SRCCRM_YMRKCL as cluster_market,
		customer_encoding.name as customer_name, 
		v2.yl_lrd as delivery_date, -- yl_lrd
		crm.D1SRCCRM_YCRMSOLD_0COUNTRY as country_key_sold_to,		
		crm.D1SRCCRM_YCRMACCM as account_manager_code,
		crm.D1SRCCRM_YQLICRBY as created_by,
		crm.D1SRCCRM_YCOMPLIST as competitors_list,		
		case when customer_encoding.cu56 in ('01','02','03') then 'AMDS' else 'Industry' end as AMDS_flag,
		amds.value as AMDS_affiliation_name, 
		
		-- crm price details			
		crm.D1SRCCRM_YCALLDT as call_date,				
		cast(crm.D1SRCCRM_YCALLDT_CALWEEK as int) as call_week,
		crm.D1SRCCRM_YCALLDT_CALYEAR as call_year,			
		crm.D1SRCCRM_YEFFP as effective_price, 
		crm.D1SRCCRM_YP0CURR as effective_price_currency, 
		crm.D1SRCCRM_YPRINSDT as pi_date,
		crm.D1SRCCRM_YPRINSTR as price_instruction,	
		crm.D1SRCCRM_YP1 as crm_p1,						
		crm.D1SRCCRM_YPP1 as crm_p1prime,				-- recommended price from the offerbook
		crm.D1SRCCRM_YPP1 - crm.D1SRCCRM_YP1 as crm_mb_plus_trans_extras, --The tranport and miniar column is not complete
		crm.D1SRCCRM_YEXTRAF as full_extra,				-- D1SRCCRM_YEXTRAF may differ from ns_model_v2.model_log_ws_crminput_v2.ydyn_e0
		result_v2.full_extras as crminput_v2_full_extra,  	-- corresponds to ns_model_v2.model_log_ws_crminput_v2.ydyn_e0
		crm.RPCRM_CP_TCKF_RPRC_EQ_BP_EUROPE as BPEQ_EU,	-- BPEQ_EU_DELIVERED 
		crm.RPCRM_CP_TCKF_RPRC_EQ_BP_CIAL as BPEQ_CIAL,	-- BPEQ_CIAL_DELIVERED

		-- P models
			-- P1 			
		psafe.p1 as p1, 
		psafe.p1 + crm.D1SRCCRM_YPP1 - crm.D1SRCCRM_YP1 as p1prime, 

			-- absP*
		absp.absolute_pstar as mtm_absolute_pstar,
		absp.absolute_pstar + crm.D1SRCCRM_YPP1 - crm.D1SRCCRM_YP1 as mtm_absolute_pstarprime, 
		absp.absolute_pstar_base_price,
		
		case when absp.is_magnet_applied = 1 then absp.absolute_pstar_base_price
     		when absp.is_magnet_applied = 0 then absp.absolute_pstar
		end as absolute_pstar,

		(case when absp.is_magnet_applied = 1 then absp.absolute_pstar_base_price
     		when absp.is_magnet_applied = 0 then absp.absolute_pstar
		end) + crm.D1SRCCRM_YPP1 - crm.D1SRCCRM_YP1 as absolute_pstarprime,

		case when absp.absolute_pstar is not null then 'yes' else 'no' end as is_absolute_pstar,
		case when absp.is_magnet_applied = 1 then 'yes' else 'no' end as is_absPstar_magnet_applied,
		absp.absolute_pstar_estimations_id,
		abspe.estimated_base_price,
		abspe.threshold as absPstar_threshold,
		abspe.training_week as absPstar_training_week,
		
			-- CM_psafe
		cm.cm_psafe,
		cm.cm_psafe + crm.D1SRCCRM_YPP1 - crm.D1SRCCRM_YP1 as cm_psafeprime,
		cm.sumcosteuroton,
		cm.redthreshold,
		cm.redthresholdprc,

		-- CM booster
		cm.cm_delta as p1_cm_delta,
		absp.contribution_margin_booster as absPstar_cm_delta,
		case when mt.model_type = 'AbsP' then absp.contribution_margin_booster else cm.cm_delta end as cm_delta,
		
		--contribution margin
		crm.D1CMCRM_YCRMCON_M as contribution_margin, 
		crm.D1CMCRM_YCRMVCBV + crm.D1CMCRM_YCRMVCDV + crm.D1CMCRM_YCRMVCZV + crm.D1CMCRM_YCRMVCFV 
		+ crm.D1CMCRM_YCRMVCGV + crm.D1CMCRM_YCRMVCOV + crm.D1CMCRM_YCRMVCPV + crm.D1CMCRM_YCRMVCSV 
		+ crm.D1CMCRM_YCRMREBAV + psafe.p1*(crm.D1CMCRM_YCRMREBVP/100) + crm.D1CMCRM_YCRMTRAV as cm_total_cost_calculated,
			-- fixed costs
		crm.D1CMCRM_YCRMCOSTP as cm_cost_pc, 
		crm.D1CMCRM_YCRMCOST as cm_cost_EUR_T, 
			-- rebate
		crm.D1CMCRM_YCRMREBAV as rebate_EUR_T, 
		crm.D1CMCRM_YCRMREBVP as rebate_pc, 
		crm.D1CMCRM_YCRMTOTR as rebate_total_EUR_T, 
			-- transport
		crm.D1CMCRM_YCRMTRAV as transport_EUR_T, 
		crm.D1CMCRM_YCRMTRAVP as transport_pc, 
			-- variable costs base
		crm.D1CMCRM_YCRMVCBV as variable_base_cost_EUR_T, 
		crm.D1CMCRM_YCRMVCBVP as variable_base_cost_pc, 
			-- variable costs extra
		crm.D1CMCRM_YCRMVCDV as vc_coil_dimension_EUR_T, 
		crm.D1CMCRM_YCRMVCDVP as vc_coil_dimension_pc, 
		crm.D1CMCRM_YCRMVCZV as vc_extra_zinc_EUR_T, 
		crm.D1CMCRM_YCRMVCZVP as vc_extra_zinc_pc, 
		crm.D1CMCRM_YCRMVCFV as vc_form_EUR_T, 
		crm.D1CMCRM_YCRMVCFVP as vc_form_pc, 
		crm.D1CMCRM_YCRMVCGV as vc_grade_EUR_T, 
		crm.D1CMCRM_YCRMVCGVP as vc_grade_pc, 
		crm.D1CMCRM_YCRMVCOV as vc_other_quality_EUR_T, 
		crm.D1CMCRM_YCRMVCOVP as vc_other_quality_pc, 
		crm.D1CMCRM_YCRMVCPV as vc_packaging_EUR_T, 
		crm.D1CMCRM_YCRMVCPVP as vc_packaging_pc, 
		crm.D1CMCRM_YCRMVCSV as vc_surface_treatment_EUR_T, 
		crm.D1CMCRM_YCRMVCSVP as vc_surface_treatment_pc,

		-- pricing product
		result_v2.pricing_product_id,
		pp_encoding.pricing_product_name,		
		result_v2.pi_delta,	
		v2.pir_date,
		result_v2.commercial_base_price_delivered as BPD_commercial, 			
		crm.D1SRCCRM_YEFFP -  result_v2.full_extras  as base_price_EU, -- BPEQ EU Delivered: “Effective price” – “Full Extras as per AM price list”
		crm.D1SRCCRM_YEFFP -  result_v2.full_extras - coalesce(result_v2.delta_extras_total,0) as base_price_commercial,			-- BPEQ Cial Delivered: “Effective price” – “Full Extras as per AM price list” – “BPEQ Cial relevant Deltas” (deviations on extras +    exception rules with flag)

		-- model v2
		coalesce(result_v2.delta_extras_total,0) as deviations,
		result_v2.delta_transport_sold_to,
		result_v2.cpp as CPP,	-- competition pricing power	
		result_v2.random_factor,

		ps.pkl_model as pkl_model,
		cast(ps.pkl_week as int) as pkl_week,
		ps.api_version as api_version, 

		v2.item_creation_date as v2_item_creation_date,
		v2.creation_time as v2_creation_time,
		v2.offerdate as v2_offerdate,
		v2.discount_deal as v2_discount_deal
	
	from
		(select *
		from ns_model_v2.model_log_ws_pstar
		where ns_model_v2.model_log_ws_pstar.pstar is not null
			and ns_model_v2.model_log_ws_pstar.pstar < 3000
			and 200 < ns_model_v2.model_log_ws_pstar.pstar
		) ps
		
	join (select * from ns_model_v2.model_log_ws_psafe where is_prod = 0) psafe
		on ps.sessionid = psafe.sessionid
	
	join ns_model_v2.model_log_ws_result_v2 result_v2 
		on ps.sessionid = result_v2.sessionid

	join
		(select v2_all.*
		from ns_model_v2.model_log_ws_crminput_v2 v2_all
			join 
				(select l_ref_doc as max_l_ref_doc
				, crmofferid as max_crmofferid
				, max(creation_time) as max_creation_time
				from ns_model_v2.model_log_ws_crminput_v2
					where l_pltyp in ('86', '87','Z3')
					and l_ref_doc is not null
					and crmofferid not like '%000010'
				group by l_ref_doc, crmofferid
				)  v2_max
			on v2_all.crmofferid = v2_max.max_crmofferid and v2_all.l_ref_doc = v2_max.max_l_ref_doc and v2_all.creation_time = v2_max.max_creation_time
		) v2 
		on ps.sessionid = v2.sessionid	
		
	left join ns_model_v2.model_log_ws_cm cm
		on ps.sessionid = cm.sessionid	
	
	left join ns_model_v2.model_log_ws_model_type mt
		on ps.sessionid = mt.sessionid
		
	join
		(select *
		from ns_historical.crmdata_full crm1 
		where crm1.D1SRCCRM_YPRCPER in ('M', 'Q', 'S', 'Y','P') 
			and crm1.D1SRCCRM_YPTCCONTR = 'N'
			and crm1.D1SRCCRM_YPTCORDER = 'N'
			and crm1.D1SRCCRM_YDISCDEAL = 'N'
			and	crm1.D1SRCCRM_YFLQUAL = 'Y'
			and crm1.D1SRCCRM_YPRFCL is not null
			and crm1.D1SRCCRM_YEFFP > 0
			and crm1.D1SRCCRM_YCALLDT not in ('00000000')
		) crm 
		on v2.crmofferid = right(crm.D1SRCCRM_YSQN, 6)
			and v2.l_ref_doc = crm.D1SRCCRM_YOPPNMBR
			and '20'+convert(varchar, v2.creation_time, 12) = crm.D1SRCCRM_YCALLDT 
			and round(crm.D1SRCCRM_YPP1,0) in (round(psafe.psafe + crm.D1SRCCRM_YPP1 - crm.D1SRCCRM_YP1,0),
											round(psafe.p1 + crm.D1SRCCRM_YPP1 - crm.D1SRCCRM_YP1,0),
											round(cm.cm_psafe + crm.D1SRCCRM_YPP1 - crm.D1SRCCRM_YP1,0))

	left join ns_model_v2.model_log_ws_absolutepstar absp
		on ps.sessionid = absp.session_id and ps.pkl_family = absp.family

	left join ns_model_v2.absolute_pstar_estimations abspe
		on absp.absolute_pstar_estimations_id = abspe.id
		
	left join ns_model.master_l_par_sf_ys_zzz172 for_csu_encoding 
		on ps.pkl_csu = for_csu_encoding.value_code
	left join ns_master.master_yocmat_yodpprfam family_encoding 
		on ps.pkl_family = family_encoding.value_code
	
	left join ns_master.master_ydyn_cu74 supra_region_encoding 
		on v2.supragregionsoldto = supra_region_encoding.value_code	
	left join ns_model.pricing_product pp_encoding 
		on result_v2.pricing_product_id = pp_encoding.pricing_product_id
	
	left join ns_master.master_yocmat_yodpsubfa sub_family_encoding 
		on crm.D1SRCCRM_YCRMSFAM = sub_family_encoding.value_code
	left join ns_master.master_l_par_sf_s_sector sector_encoding 
		on crm.D1SRCCRM_YCRMSFCC_YSECTOR = sector_encoding.value_code
	left join ns_master.master_ydyn_qu02 steel_grade_encoding 
		on crm.D1SRCCRM_YCRMQU02 = steel_grade_encoding.value_code
	left join ns_master.master_l_par_sf_ys_zzz143 for_cu_encoding 
		on crm.D1SRCCRM_YCRMSFCC_YCRMZ143 = for_cu_encoding.value_code	
	left join ns_master.master_ydyn_co25 coating_specification_encoding 
		on crm.D1SRCCRM_YCRMCO25 = coating_specification_encoding.value_code
	
	left join ns_master.customerdata_extended customer_encoding 
		on crm.D1SRCCRM_YCRMSFCC = customer_encoding.SCUST	
	left join ns_master.master_l_par_sf_s_sector sector 
		on customer_encoding.sector = sector.value_code
	left join ns_master.master_l_par_sf_s_branch branch 
		on customer_encoding.branch = branch.value_code		
	left join ns_master.master_ydyn_cu56 amds 
		on customer_encoding.cu56 = amds.value_code 	 

	left join ns_model_v2.failsafe_management_input failsafe_input
		on ps.pkl_csu = failsafe_input.l_par_sf_ys_zzz172 and ps.pkl_family = failsafe_input.yocmat_yodpprfam