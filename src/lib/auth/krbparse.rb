# encoding: utf-8
# ------------------------------------------------------------------------------
# Copyright (c) 2016 SUSE LINUX GmbH, Nuernberg, Germany.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact SUSE Linux GmbH.
#
# ------------------------------------------------------------------------------
#
# Module: Implementation of a parser for krb5.conf.
# Author: Howard Guo <hguo@suse.com>

module Auth
    # Implement parser of Kerberos configuration file.
    class KrbParse
        # Parse krb5.conf text into a hash structure representation.
        def self.parse(krb_conf_text)
            long_attr1 = ''
            long_attr2 = ''
            sect = ''
            new_krb_conf = {'include' => [], 'libdefaults' => {}, 'realms' => {}, 'domain_realm' => {}, 'logging' => {}}
            # Break down sections and key-value pairs
            krb_conf_text.split(/\n/).each{ |line|
                # Throw away comment
                comment_match = /^\s*[#;].*$/.match(line)
                if comment_match
                    next
                end
                # Skip empty lines
                next if line.match?(/^\s+$/)
                # Remember include/includedir directives
                include_match = /^(includedir|include|module)\s+(.+)$/.match(line)
                if include_match
                    new_krb_conf['include'] += ["#{include_match[1]} #{include_match[2]}"]
                    next
                end
                # Remember section name
                sect_match = /^\[([.a-zA-Z0-9_-]+)\]\s*$/.match(line)
                if sect_match
                    # remember current section
                    sect = sect_match[1]
                    # Bug 1122026: krb5.conf sections can have a variable amount
                    # of characters appended to the name, and still be valid.
                    # domain_realm for example could have an 's' appended, but
                    # is not the documented section title.
                    new_krb_conf.each { |k, v|
                        if sect_match[1].start_with?(k)
                            sect = k
                            break
                        end
                    }
                    next
                end
                # Remember expanded attribute
                long_attr_match = /^\s*([.a-zA-Z0-9_-]+)\s*=\s*{\s*$/.match(line)
                if long_attr_match
                    if long_attr1 == ''
                        long_attr1 = long_attr_match[1]
                    elsif long_attr2 == ''
                        long_attr2 = long_attr_match[1]
                    end
                    next
                end
                # Closing an expanded attribute
                close_long_attr_match = /^\s*}\s*$/.match(line)
                if close_long_attr_match
                    if !new_krb_conf[sect]
                        new_krb_conf[sect] = {}
                    end
                    sect_conf = new_krb_conf[sect]
                    if long_attr1 != ''
                        if !sect_conf[long_attr1]
                            sect_conf[long_attr1] = {}
                        end
                        sect_conf = sect_conf[long_attr1]
                    end
                    if long_attr2 != ''
                        long_attr2 = ''
                    elsif long_attr1 != ''
                        long_attr1 = ''
                    end
                    next
                end
                # Note down key-value pairs in the current section
                kv_match = /^\s*([.a-zA-Z0-9_-]+)\s*=\s*(.+)\s*$/.match(line)
                if kv_match
                    if !new_krb_conf[sect]
                        new_krb_conf[sect] = {}
                    end
                    sect_conf = new_krb_conf[sect]
                    if long_attr1 != ''
                        if !sect_conf[long_attr1]
                            sect_conf[long_attr1] = {}
                        end
                        sect_conf = sect_conf[long_attr1]
                    end
                    if long_attr2 != ''
                        if !sect_conf[long_attr2]
                            sect_conf[long_attr2] = {}
                        end
                        sect_conf = sect_conf[long_attr2]
                    end
                    key = kv_match[1]
                    val = kv_match[2]
                    # A key can hold an array of values
                    existing_value = sect_conf[key]
                    if existing_value && existing_value.kind_of?(::String)
                        sect_conf[key] = [existing_value, val]
                    elsif existing_value && existing_value.kind_of?(::Array)
                        sect_conf[key] = existing_value + [val]
                    else
                        sect_conf[key] = val
                    end
                    next
                end
                # Note down single value
                key = ''
                v_match = /^\s*([^{}\n\r]+)\s*$/.match(line)
                if v_match && !long_attr1.nil?
                    if !new_krb_conf[sect]
                        new_krb_conf[sect] = {}
                    end
                    sect_conf = new_krb_conf[sect]
                    if long_attr1 != ''
                        key = long_attr1
                    end
                    if long_attr2 != ''
                        # long_attr2 is a key under long_attr1
                        if !sect_conf[long_attr1]
                            sect_conf[long_attr1] = {}
                        end
                        sect_conf = sect_conf[long_attr1]
                        key = long_attr2
                    end
                    val = v_match[1]
                    # A key can hold an array of values
                    existing_value = sect_conf[key]
                    if existing_value && existing_value.kind_of?(::String)
                        sect_conf[key] = [existing_value, val]
                    elsif existing_value && existing_value.kind_of?(::Array)
                        sect_conf[key] = existing_value + [val]
                    else
                        sect_conf[key] = val
                    end
                    next
                end
            }
            # These two realm attributes must be placed inside an array
            new_krb_conf['realms'].each {|_, conf|
                ['kdc', 'auth_to_local'].each { |attr|
                    if conf[attr].kind_of?(::String)
                        conf[attr] = [conf[attr]]
                    end
                }
            }
            return new_krb_conf
        end
    end
end
