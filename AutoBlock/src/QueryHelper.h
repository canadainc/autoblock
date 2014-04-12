#ifndef QUERYHELPER_H_
#define QUERYHELPER_H_

#include <QStringList>
#include <QFileSystemWatcher>

namespace canadainc {
    class AppLogFetcher;
	class CustomSqlDataSource;
}

namespace bb {
    namespace pim {
        namespace message {
            class MessageService;
        }
    }
}

namespace autoblock {

using namespace canadainc;
using namespace bb::pim::message;

class QueryHelper : public QObject
{
	Q_OBJECT

	AppLogFetcher* m_reporter;
	CustomSqlDataSource* m_sql;
    MessageService* m_ms;
    qint64 m_lastUpdate;
    QFileSystemWatcher m_updateWatcher;

    void recheck(int &count, const char* slotName);
    void validateResult(QStringList const& list);

private slots:
    void databaseUpdated(QString const& path);
    void dataLoaded(int id, QVariant const& data);
    void onError(QString const& errorMessage);

Q_SIGNALS:
    void dataReady(int id, QVariant const& data);

public:
	QueryHelper(CustomSqlDataSource* sql, AppLogFetcher* reporter);
	virtual ~QueryHelper();

    Q_INVOKABLE void clearBlockedKeywords();
    Q_INVOKABLE void clearBlockedSenders();
    Q_INVOKABLE void cleanInvalidEntries();
    Q_INVOKABLE void clearLogs();
    Q_INVOKABLE void fetchAllBlockedKeywords();
    Q_INVOKABLE void fetchAllBlockedSenders();
    Q_INVOKABLE void fetchAllLogs();
    Q_INVOKABLE void fetchLatestLogs();
    Q_INVOKABLE QStringList block(QVariantList const& numbers);
    Q_INVOKABLE QStringList blockKeywords(QVariantList const& keywords);
    Q_INVOKABLE QStringList unblock(QVariantList const& senders);
    Q_INVOKABLE QStringList unblockKeywords(QVariantList const& keywords);
    Q_SLOT void checkDatabase();
};

} /* namespace oct10 */
#endif /* QUERYHELPER_H_ */
