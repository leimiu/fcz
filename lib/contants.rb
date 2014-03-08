module FCZ
  DIR_BASE=::WORK_DIR

  SYS_CONFIG="#{DIR_BASE}/config/config.yml"

  TPL_XLS="#{DIR_BASE}/tpl/fcz_tpl_xls.tpl"
  TPL_CSV="#{DIR_BASE}/tpl/fcz_tpl_csv.tpl"

  DIR_LOG="#{DIR_BASE}/logs/"
  DIR_OUT="#{DIR_BASE}/out/"
  DIR_SHOT="#{DIR_BASE}/shots/"

  FILE_POS="#{DIR_BASE}/config/lastpos.txt"

  URL_FCZ='http://www.capse.com.cn/index.asp?page='

  DEFAULT_ENCODING='gb2312'
end