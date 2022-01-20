.PHONY: install
install:
	@echo "Installing blockor"
	@cp -Rv ../usr /
	@cp -Rv etc /
	@cp -Rv usr /
	@echo "Successfully installed"

.PHONY: uninstall
uninstall:
	@echo "Removing blockor"
	@rm -vf /usr/local/bin/blockor
	@rm -rvf /usr/local/libexec/blockord.sh
	@rm -rvf /usr/local/share/examples/blockor/blockor.sample.conf
	@rm -rvf /etc/rc.d/blockord
	@rm -rvf /usr/local/etc/blockor.conf
	@echo "Successfully removed"
