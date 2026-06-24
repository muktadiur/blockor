.PHONY: install
install:
	@echo "Installing blockor"
	@if [ `uname -s | tr 'A-Z' 'a-z'` = "openbsd" ]; then \
		cp -Rv openbsd/usr / ; \
		cp -Rv openbsd/etc / ; \
	else \
		cp -Rv freebsd/usr / ; \
	fi
	@cp -Rv usr /
	@mkdir -p /var/db/blockor /var/run/blockor
	@chmod 700 /var/db/blockor /var/run/blockor
	@chmod 755 /usr/local/bin/blockor /usr/local/libexec/blockor/blockord.sh
	@echo "Successfully installed"

.PHONY: uninstall
uninstall:
	@echo "Removing blockor"
	-@/usr/local/bin/blockor stop 2>/dev/null || true
	-@/usr/local/bin/blockor disable 2>/dev/null || true
	@if [ `uname -s | tr 'A-Z' 'a-z'` = "openbsd" ]; then \
		rm -vf /etc/rc.d/blockord ; \
	else \
		rm -vf /usr/local/etc/rc.d/blockord ; \
	fi
	@rm -vf /usr/local/bin/blockor
	@rm -rvf /usr/local/libexec/blockor
	@rm -vf /usr/local/etc/blockor.conf
	@rm -vf /usr/local/etc/blockor.pf.conf
	@rm -vf /usr/local/man/man8/blockor.8.gz
	@rm -rvf /usr/local/share/examples/blockor
	@echo "Kept: /var/db/blockor (state) and /var/log/blockord.log (log)."
	@echo "Remove them manually if you no longer need the ban history."
	@echo "Successfully removed"

.PHONY: test
test:
	@sh tests/run_tests.sh
