<?php

// https://www.mediawiki.org/wiki/Extension:OpenIDConnect

## OpenIDConnect Configuration

# Extension Pluggable Auth needs to be loaded first
wfLoadExtension( 'PluggableAuth' );
wfLoadExtension( 'OpenIDConnect' );